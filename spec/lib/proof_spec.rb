require 'spec_helper'

describe Proof do
  let(:provers) { [1,2].map { create(:prover, :with_sequenced_name) } }
  let(:timeout) { 10 }
  let(:theorem) { create :theorem }
  let(:ontology) { theorem.ontology }
  let(:theorem2) { create :theorem, ontology: ontology }
  let(:axioms) { (1..3).map { create :axiom, ontology: ontology } }
  let(:ontology_version) { ontology.current_version }
  let(:repository) { ontology.repository }
  let(:params) do
    {
      repository_id: repository.to_param,
      ontology_id: ontology.to_param,
      proof: {prover_ids: [*provers.map(&:id).map(&:to_s), ''],
              axiom_selection_method: AxiomSelection::METHODS.first,
              timeout: timeout}
    }
  end

  let(:options) { { timeout: timeout} }
  before do
    ontology.theorems << theorem2
    ontology.save!
  end

  context 'validations' do
    it 'is valid' do
      expect(Proof.new(params).valid?).to be(true)
    end

    it 'is valid without provers' do
      params[:proof][:prover_ids] = ['']
      expect(Proof.new(params).valid?).to be(true)
    end

    it 'is valid without a timeout' do
      params[:proof][:timeout] = nil
      expect(Proof.new(params).valid?).to be(true)
    end

    it 'is not valid with bad provers' do
      params[:proof][:prover_ids] = ['-1', '']
      expect(Proof.new(params).valid?).to be(false)
    end

    it 'is not valid with bad axiom_selection_method' do
      params[:proof][:axiom_selection_method] = :'_not_existent'
      expect(Proof.new(params).valid?).to be(false)
    end

    it 'is not valid with a too little timeout' do
      params[:proof][:timeout] = Proof::TIMEOUT_RANGE.first - 1
      expect(Proof.new(params).valid?).to be(false)
    end

    it 'is not valid with a too high timeout' do
      params[:proof][:timeout] = Proof::TIMEOUT_RANGE.last + 1
      expect(Proof.new(params).valid?).to be(false)
    end
  end

  context 'usage for ontology_version' do
    let(:proof) { Proof.new(params) }
    let(:theorems_count) { ontology.theorems.original.count }

    it 'theorem? is false' do
      expect(proof.theorem?).to be(false)
    end

    it 'has the ontology_version as proof obligation' do
      expect(proof.proof_obligation).to eq(ontology_version)
    end

    it 'proof_attempts has "#provers * #theorems" many entries' do
      # We need to except the empty string from the counting
      provers_count = params[:proof][:prover_ids].size - 1
      expect(proof.proof_attempts.size).to eq(provers_count * theorems_count)
    end


    context 'axiom selection' do
      let(:params_modified) do
        params.merge({proof: params[:proof].merge({
          axioms: axioms.map(&:id)
        })})
      end
      let(:proof_modified) { Proof.new(params_modified) }

      before { proof_modified.save! }

      it 'is of the correct class' do
        expect(proof_modified.axiom_selection.specific.class).
          to eq(ManualAxiomSelection)
      end

      it 'is correct' do
        expect(proof_modified.axiom_selection.axioms).
          to match_array(axioms)
      end
    end

    context 'on save!' do
      before do
        allow(ProofExecutionWorker).to receive(:perform_async)
      end

      it 'with the proof attempts saved' do
        proof.proof_attempts.each do |proof_attempt|
          allow(proof_attempt).to receive(:save!).and_call_original
        end
        proof.save!
        proof.proof_attempts.each do |proof_attempt|
          expect(proof_attempt).to have_received(:save!)
        end
      end

      context 'ProofAttemptConfigurations' do
        before { proof.save! }

        it 'are created' do
          proof.proof_attempts.each do |proof_attempt|
            expect(proof_attempt.reload.proof_attempt_configuration).
              not_to be(nil)
          end
        end

        it 'have the provers set' do
          expect(proof.proof_attempts.
                 map(&:reload).
                 map(&:proof_attempt_configuration).
                 map(&:prover).uniq).to match_array(provers)
        end

        it 'have the timeout set' do
          proof.proof_attempts.each do |proof_attempt|
            expect(proof_attempt.reload.proof_attempt_configuration.timeout).
              to eq(timeout)
          end
        end
      end

      it 'with the proof attempts saved' do
        proof.proof_attempts.each do |proof_attempt|
          allow(proof_attempt).to receive(:save!).and_call_original
        end
        proof.save!
        proof.proof_attempts.each do |proof_attempt|
          expect(proof_attempt).to have_received(:save!)
        end
      end
    end
  end

  context 'usage for theorem' do
    let(:theorem_params) { params.merge(theorem_id: theorem.to_param) }
    let(:proof) { Proof.new(theorem_params) }

    it 'theorem? is true' do
      expect(proof.theorem?).to be(true)
    end

    it 'has the theorem as proof obligation' do
      expect(proof.proof_obligation).to eq(theorem)
    end

    it 'proof_attempts has "#provers" many entries' do
      # We need to except the empty string from the counting
      provers_count = params[:proof][:prover_ids].size - 1
      expect(proof.proof_attempts.size).to eq(provers_count)
    end

    context 'axiom selection' do
      let(:params_modified) do
        theorem_params.merge({proof: params[:proof].merge({
          axioms: axioms.map(&:id)
        })})
      end
      let(:proof_modified) { Proof.new(params_modified) }

      before { proof_modified.save! }

      it 'is of the correct class' do
        expect(proof_modified.axiom_selection.specific.class).
          to eq(ManualAxiomSelection)
      end

      it 'is correct' do
        expect(proof_modified.axiom_selection.axioms).
          to match_array(axioms)
      end
    end

    context 'on save!' do
      before do
        allow(ProofExecutionWorker).to receive(:perform_async)
      end

      it 'with the proof attempts saved' do
        proof.proof_attempts.each do |proof_attempt|
          allow(proof_attempt).to receive(:save!).and_call_original
        end
        proof.save!
        proof.proof_attempts.each do |proof_attempt|
          expect(proof_attempt).to have_received(:save!)
        end
      end

      context 'ProofAttemptConfigurations' do
        before { proof.save! }

        it 'are created' do
          proof.proof_attempts.each do |proof_attempt|
            expect(proof_attempt.reload.proof_attempt_configuration).
              not_to be(nil)
          end
        end

        it 'have the provers set' do
          expect(proof.proof_attempts.
                 map(&:reload).
                 map(&:proof_attempt_configuration).
                 map(&:prover).uniq).to match_array(provers)
        end

        it 'have the timeout set' do
          proof.proof_attempts.each do |proof_attempt|
            expect(proof_attempt.reload.proof_attempt_configuration.timeout).
              to eq(timeout)
          end
        end
      end

      it 'with the proof attempts saved' do
        proof.proof_attempts.each do |proof_attempt|
          allow(proof_attempt).to receive(:save!).and_call_original
        end
        proof.save!
        proof.proof_attempts.each do |proof_attempt|
          expect(proof_attempt).to have_received(:save!)
        end
      end
    end
  end
end
