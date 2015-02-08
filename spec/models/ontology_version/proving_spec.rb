require 'spec_helper'

describe 'OntologyVersion - Proving' do
  setup_hets
  let(:user) { create :user }
  let(:parent_ontology) { create :distributed_ontology }

  before do
    parse_this(user, parent_ontology, hets_out_file('Simple_Implications'))
    stub_hets_for(prove_out_file('Simple_Implications'), command: 'prove', method: :post)
  end

  let(:ontology) { parent_ontology.children.find_by_name('Group') }
  let(:version) { ontology.current_version }

  context 'without exception' do
    before do
      version.async_prove
      Worker.drain
    end

    it 'should be done' do
      expect(ontology.reload.state).to eq('done')
    end
  end

  context 'on sidekiq shutdown' do
    before do
      allow(Hets).to receive(:prove_via_api).and_raise(Sidekiq::Shutdown)
      version.async_prove
      expect { Worker.drain }.to raise_error(Sidekiq::Shutdown)
    end

    it 'should reset status to pending' do
      expect(ontology.reload.state).to eq('pending')
    end
  end

  context 'on hets error' do
    before do
      allow(Hets).to receive(:prove_via_api).
        and_raise(Hets::HetsError, 'serious error')
      version.async_prove
      expect { Worker.drain }.to raise_error(Hets::HetsError)
    end

    it 'should set status to failed' do
      expect(ontology.reload.state).to eq('failed')
    end
  end

  context 'on failed to update state' do
    before do
      allow(Hets).to receive(:prove_via_api).
        and_raise(Hets::HetsError, 'first error')
      allow_any_instance_of(OntologyVersion).to receive(:after_failed).
        and_raise('second exception')
      version.async_prove
      expect { Worker.drain }.to raise_error(RuntimeError)
    end

    it 'should set status to failed on ontology' do
      expect(ontology.reload.state).to eq('failed')
    end

    it 'should set state to failed' do
      expect(version.reload.state).to eq('failed')
    end

    it 'should contain the nested error' do
      nested_error_regex = /nested exception.*second exception.*first error/im
      expect(version.reload.last_error).to match(nested_error_regex)
    end
  end

  context 'evaluation' do
    before do
      version.async_prove
      Worker.drain
    end

    it 'all theorems solved' do
      ontology.theorems.each do |theorem|
        expect(theorem.proof_status.solved?).to be(true)
      end
    end

    context 'first theorem' do
      let(:theorem) { ontology.theorems.first }

      it 'have a proof_attempt' do
        expect(theorem.proof_attempts.length).to eq(1)
      end

      it 'have "proven" status' do
        proven = create :proof_status_proven
        expect(theorem.proof_status).to eq(proven)
      end

      context 'proof attempt' do
        let(:proof_attempt) { theorem.proof_attempts.first }

        it 'have "proven" status' do
          proven = create :proof_status_proven
          expect(proof_attempt.proof_status).to eq(proven)
        end

        it 'have "SPASS" prover' do
          expect(proof_attempt.prover).to eq('SPASS')
        end

        it 'have prover output' do
          expect(proof_attempt.prover_output).not_to be_nil
        end

        it 'have a tactic script' do
          expect(proof_attempt.tactic_script).not_to be_nil
        end

        it 'have non-negative time-taken information' do
          expect(proof_attempt.time_taken).to be >= 0
        end

        it 'have three used axioms' do
          expect(proof_attempt.used_axioms.map(&:name)).
            to include('leftunit', 'Ax2', 'ga_assoc___+__')
        end
      end

      context 'prove a second time' do
        before do
          version.async_prove
          Worker.drain
        end

        it 'create another proof_attempt' do
          expect(theorem.proof_attempts.length).to eq(2)
        end
      end
    end
  end
end
