require 'spec_helper'

describe CollectiveProofAttempt do
  setup_hets
  let(:prover) { Prover.first }
  let(:user) { create :user }
  let(:repository) { create :repository }

  let(:ontology_fixture_file) { %w(prove/Simple_Implications casl) }
  let(:ontology_filepath) { ontology_fixture_file.join('.') }
  before do
    stub_hets_for(ontology_filepath)
    stub_hets_for(ontology_filepath, command: 'prove', method: :post)
  end
  let(:parent_ontology_version) do
    version = version_for_file(repository,
                               ontology_file(*ontology_fixture_file))
    version.parse
    version
  end

  let(:parent_ontology) { parent_ontology_version.ontology }
  let(:ontology) { parent_ontology.children.find_by_name('Group') }
  let(:ontology_version) { ontology.current_version }

  let(:theorem) { ontology.theorems.find_by_name('rightunit') }
  let(:theorem2) { ontology.theorems.find_by_name('zero_plus') }
  let(:theorems) { [theorem, theorem2] }

  let(:proof_attempt) { create :proof_attempt, theorem: theorem, prover: nil }
  let(:proof_attempt2) { create :proof_attempt, theorem: theorem2, prover: nil }
  let(:proof_attempts) { [proof_attempt, proof_attempt2] }

  let(:status_open) { ProofStatus.find('OPN') }
  let(:status_proven) { ProofStatus.find('THM') }

  context 'on theorem' do
    context 'before proving' do
      it "proof_attempt's proof_status is OPN" do
        expect(proof_attempt.reload.proof_status).to eq(status_open)
      end

      it "theorem's proof_status is OPN" do
        expect(theorem.reload.proof_status).to eq(status_open)
      end
    end

    context 'after proving' do
      let(:options_to_attempts) do
        {Hets::ProveOptions.new(prover: prover) => [proof_attempt]}
      end
      let(:cpa) { CollectiveProofAttempt.new(theorem, options_to_attempts) }
      before do
        [cpa.send(:ontology_version), *theorems, *proof_attempts].each do |obj|
          allow(obj).to receive(:update_state!).and_call_original
        end
      end

      context 'without exception' do
        before { cpa.run }

        it 'set state of theorem to processing' do
          expect(theorem).to have_received(:update_state!).with(:processing)
        end

        it 'set state of cpa.ontology_version to processing' do
          expect(cpa.send(:ontology_version)).
            to have_received(:update_state!).with(:processing)
        end

        it 'cpa.ontology_version equals ontology_version' do
          expect(cpa.send(:ontology_version)).to eq(ontology_version)
        end

        it 'set state of proof_attempt to processing' do
          expect(proof_attempt).
            to have_received(:update_state!).with(:processing)
        end

        it "proof_attempt's proof_status is THM" do
          expect(proof_attempt.reload.proof_status).to eq(status_proven)
        end

        it "theorem's proof_status is THM" do
          expect(theorem.reload.proof_status).to eq(status_proven)
        end

        it "proof_attempt2's proof_status is OPN" do
          expect(proof_attempt2.reload.proof_status).to eq(status_open)
        end

        it "theorem2's proof_status is OPN" do
          expect(theorem2.reload.proof_status).to eq(status_open)
        end

        it 'state of proof_attempt is done in the end' do
          expect(proof_attempt.reload.state).to eq('done')
        end

        it 'state of theorem is done in the end' do
          expect(theorem.reload.state).to eq('done')
        end

        it "ontology_version's state is done in the end" do
          expect(ontology_version.reload.state).to eq('done')
        end
      end

      context "with hets result 'nothing to prove'" do
        before do
          allow_any_instance_of(Hets::ProveCaller).to receive(:call).
            and_return(StringIO.new('nothing to prove'))
        end

        it 'raise a hets error' do
          expect { cpa.run }.to raise_error(Hets::Errors::HetsFileError)
        end
      end

      context "with hets result beginning with '*** Error:'" do
        let(:msg) { 'some error message' }
        before do
          allow_any_instance_of(UriFetcher::PostCaller).
            to receive(:call).
            and_raise(UriFetcher::UnfollowableResponseError.
              new(last_response: OpenStruct.new(code: '422',
                                                body: "*** Error: #{msg}")))
        end

        it 'raise a hets error' do
          expect { cpa.run }.to raise_error(Hets::Errors::HetsFileError, msg)
        end
      end

      context 'with hets returning invalid json' do
        before do
          allow_any_instance_of(Hets::ProveCaller).to receive(:call).
            and_return(StringIO.new('not valid json'))
        end

        it 'raise a parser error' do
          expect { cpa.run }.to raise_error(Hets::JSONParser::ParserError)
        end
      end

      context 'error handling' do
        let(:error_message) { 'some error message' }
        before do
          allow_any_instance_of(Ontology).to receive(:import_proof).
            and_raise(Hets::Errors::HetsFileError, error_message)
          begin
            cpa.run
          rescue Hets::Errors::HetsFileError
          end
        end

        it "proof_attempt's proof_status is OPN" do
          expect(proof_attempt.reload.proof_status).to eq(status_open)
        end

        it "theorem's proof_status is OPN" do
          expect(theorem.reload.proof_status).to eq(status_open)
        end

        it "proof_attempt2's proof_status is OPN" do
          expect(proof_attempt2.reload.proof_status).to eq(status_open)
        end

        it "theorem2's proof_status is OPN" do
          expect(theorem2.reload.proof_status).to eq(status_open)
        end

        it 'state of proof_attempt is failed in the end' do
          expect(proof_attempt.reload.state).to eq('failed')
        end

        it 'state of theorem is failed in the end' do
          expect(theorem.reload.state).to eq('failed')
        end

        it "ontology_version's state is failed in the end" do
          expect(ontology_version.reload.state).to eq('failed')
        end

        it 'last_error of proof_attempt contains the error message' do
          expect(proof_attempt.reload.last_error).to include(error_message)
        end

        it 'last_error of theorem contains the error message' do
          expect(theorem.reload.last_error).to include(error_message)
        end

        it "last_error of ontology_version contains the error message" do
          expect(ontology_version.reload.last_error).to include(error_message)
        end
      end
    end
  end

  context 'on ontology_version' do
    context 'before proving' do
      it "each proof_attempt's proof_status is OPN" do
        proof_attempts.each do |proof_attempt|
          expect(proof_attempt.reload.proof_status).to eq(status_open)
        end
      end

      it "each theorem's proof_status is OPN" do
        theorems.each do |theorem|
          expect(theorem.reload.proof_status).to eq(status_open)
        end
      end
    end

    context 'after proving' do
      let(:options_to_attempts) do
        {Hets::ProveOptions.new(prover: prover) => proof_attempts}
      end
      let(:cpa) do
        CollectiveProofAttempt.new(ontology_version, options_to_attempts)
      end
      before do
        [cpa.send(:ontology_version), *proof_attempts].each do |obj|
          allow(obj).to receive(:update_state!).and_call_original
        end
      end

      context 'without exception' do
        before { cpa.run }

        it 'set state of cpa.ontology_version to processing' do
          expect(cpa.send(:ontology_version)).
            to have_received(:update_state!).with(:processing)
        end

        it 'cpa.ontology_version equals ontology_version' do
          expect(cpa.send(:ontology_version)).to eq(ontology_version)
        end

        it 'set state of each proof_attempt to processing' do
          proof_attempts.each do |proof_attempt|
            expect(proof_attempt).
              to have_received(:update_state!).with(:processing)
          end
        end

        it "each proof_attempt's proof_status is THM" do
          proof_attempts.each do |proof_attempt|
            expect(proof_attempt.reload.proof_status).to eq(status_proven)
          end
        end

        it "each theorem's proof_status is THM" do
          theorems.each do |theorem|
            expect(theorem.reload.proof_status).to eq(status_proven)
          end
        end

        it "each proof_attempt's is done in the end" do
          proof_attempts.each do |proof_attempt|
            expect(proof_attempt.reload.state).to eq('done')
          end
        end

        it "each theorem's state is done in the end" do
          theorems.each do |theorem|
            expect(theorem.reload.state).to eq('done')
          end
        end

        it "ontology_version's state is done in the end" do
          expect(ontology_version.reload.state).to eq('done')
        end
      end

      context "with hets result 'nothing to prove'" do
        before do
          allow_any_instance_of(Hets::ProveCaller).to receive(:call).
            and_return(StringIO.new('nothing to prove'))
        end

        it 'raise a hets error' do
          expect { cpa.run }.to raise_error(Hets::Errors::HetsFileError)
        end
      end

      context "with hets result beginning with '*** Error:'" do
        let(:msg) { 'some error message' }
        before do
          allow_any_instance_of(UriFetcher::PostCaller).
            to receive(:call).
            and_raise(UriFetcher::UnfollowableResponseError.
              new(last_response: OpenStruct.new(code: '422',
                                                body: "*** Error: #{msg}")))
        end

        it 'raise a hets error' do
          expect { cpa.run }.to raise_error(Hets::Errors::HetsFileError, msg)
        end
      end

      context 'with hets returning invalid json' do
        before do
          allow_any_instance_of(Hets::ProveCaller).to receive(:call).
            and_return(StringIO.new('not valid json'))
        end

        it 'raise a parser error' do
          expect { cpa.run }.to raise_error(Hets::JSONParser::ParserError)
        end
      end

      context 'error handling' do
        let(:error_message) { 'some error message' }
        before do
          allow_any_instance_of(Ontology).to receive(:import_proof).
            and_raise(Hets::Errors::HetsFileError, error_message)
          begin
            cpa.run
          rescue Hets::Errors::HetsFileError
          end
        end

        it "each proof_attempt's proof_status is OPN" do
          proof_attempts.each do |proof_attempt|
            expect(proof_attempt.reload.proof_status).to eq(status_open)
          end
        end

        it "each theorem's proof_status is OPN" do
          theorems.each do |theorem|
            expect(theorem.reload.proof_status).to eq(status_open)
          end
        end

        it "each proof_attempt's is failed in the end" do
          proof_attempts.each do |proof_attempt|
            expect(proof_attempt.reload.state).to eq('failed')
          end
        end

        it "each theorem's state is failed in the end" do
          theorems.each do |theorem|
            expect(theorem.reload.state).to eq('failed')
          end
        end

        it "ontology_version's state is failed in the end" do
          expect(ontology_version.reload.state).to eq('failed')
        end

        it "each proof_attempt's last_error contains the error message" do
          proof_attempts.each do |proof_attempt|
            expect(proof_attempt.reload.last_error).to include(error_message)
          end
        end

        it "each theorem's last_error contains the error message" do
          theorems.each do |theorem|
            expect(theorem.reload.last_error).to include(error_message)
          end
        end

        it "ontology_version's last_error contains the error message" do
          expect(ontology_version.reload.last_error).to include(error_message)
        end
      end
    end
  end
end
