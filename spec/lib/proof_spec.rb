require 'spec_helper'

describe Proof do
  let(:provers) { [1,2].map { create(:prover, :with_sequenced_name) } }
  let(:timeout) { 10 }
  let(:theorem) { create :theorem }
  let(:ontology) { theorem.ontology }
  let(:theorem2) { create :theorem, ontology: ontology }
  let(:ontology_version) { ontology.current_version }
  let(:repository) { ontology.repository }
  let(:params) do
    {
      repository_id: repository.to_param,
      ontology_id: ontology.to_param,
      proof: {prover_ids: [*provers.map(&:id).map(&:to_s), ''],
              timeout: timeout}
    }
  end
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
    let(:theorems_count) { ontology.theorems.count }

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

    it 'prove_options_list contains the provers' do
      expect(proof.prove_options_list).
        to eq(provers.map { |prover| Hets::ProveOptions.new(prover: prover) })
    end

    it 'map ProveOptions to a list of "theorems count" many ProofAttempt ids' do
      proof.options_to_attempts_hash.keys.each do |options|
        expect(proof.options_to_attempts_hash[options].size).
          to eq(theorems_count)
      end
    end

    context 'normalizing the options to attempts map' do
      let(:proof_attempts) { proof.proof_attempts }
      before { proof_attempts.each(&:save!) }

      it 'has the ids of the proof_attempts' do
        proof_attempt_ids = proof_attempts.map(&:id)

        normalized_options_to_attempts = {}
        # Each options gets mapped to the ProofAttempt ids for the Theorems
        # in this OntologyVersion. Because there are two Theorems, each options
        # get two ids:
        proof.options_to_attempts_hash.keys.each_with_index do |options, i|
          first, last = [0, 1].map { |id| 2 * i + id }
          normalized_options_to_attempts[options.to_json] =
            proof_attempt_ids[first..last]
        end

        expect(proof.send(:normalize_for_async_call,
                          proof.options_to_attempts_hash)).
          to eq(normalized_options_to_attempts)
      end
    end

    context 'on save!' do
      before do
        allow(CollectiveProofAttemptWorker).to receive(:perform_async)
      end

      it 'gets the normalized options map' do
        allow(proof).to receive(:normalize_for_async_call).
          with(proof.options_to_attempts_hash)
        proof.save!
        expect(proof).to have_received(:normalize_for_async_call).
          with(proof.options_to_attempts_hash)
      end

      it 'with the sate updated to pending' do
        allow(proof.send(:ontology_version)).
          to receive(:update_state!).and_call_original
        proof.save!
        expect(proof.send(:ontology_version)).
          to have_received(:update_state!).with(:pending)
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
              not_to be_nil
          end
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

      it 'with the normalized options map' do
        allow(proof).to receive(:normalize_for_async_call).
          with(proof.options_to_attempts_hash).
          and_return(:normalized_options_to_attempts)
        proof.save!
        expect(CollectiveProofAttemptWorker).
          to have_received(:perform_async).
          with(OntologyVersion.to_s, ontology_version.id,
               :normalized_options_to_attempts)
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

    it 'proof_attempts has "#provers * #theorems" many entries' do
      # We need to except the empty string from the counting
      provers_count = params[:proof][:prover_ids].size - 1
      expect(proof.proof_attempts.size).to eq(provers_count)
    end

    it 'prove_options_list contains the provers' do
      expect(proof.prove_options_list).
        to eq(provers.map { |prover| Hets::ProveOptions.new(prover: prover) })
    end

    it 'map ProveOptions to a list of "theorems count" many ProofAttempt ids' do
      proof.options_to_attempts_hash.keys.each do |options|
        expect(proof.options_to_attempts_hash[options].size).to eq(1)
      end
    end

    context 'normalizing the options to attempts map' do
      let(:proof_attempts) { proof.proof_attempts }
      before { proof_attempts.each(&:save!) }

      it 'has the ids of the proof_attempts' do
        proof_attempt_ids = proof_attempts.map(&:id)

        normalized_options_to_attempts = {}
        # Each options gets mapped to the ProofAttempt ids "for the Theorems
        # in this Theorem". A Theorem always stands for itself and thus there is
        # exactly one ProofAttempt per options:
        proof.options_to_attempts_hash.keys.each_with_index do |options, i|
          normalized_options_to_attempts[options.to_json] =
            [proof_attempt_ids[i]]
        end

        expect(proof.send(:normalize_for_async_call,
                          proof.options_to_attempts_hash)).
          to eq(normalized_options_to_attempts)
      end
    end

    context 'on save!' do
      before do
        allow(CollectiveProofAttemptWorker).to receive(:perform_async)
      end

      it 'gets the normalized options map' do
        allow(proof).to receive(:normalize_for_async_call).
          with(proof.options_to_attempts_hash)
        proof.save!
        expect(proof).to have_received(:normalize_for_async_call).
          with(proof.options_to_attempts_hash)
      end

      it 'with the sate updated to pending' do
        allow(proof.send(:ontology_version)).
          to receive(:update_state!).and_call_original
        proof.save!
        expect(proof.send(:ontology_version)).
          to have_received(:update_state!).with(:pending)
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
              not_to be_nil
          end
        end

        it 'have the timeout set' do
          proof.proof_attempts.each do |proof_attempt|
            expect(proof_attempt.reload.proof_attempt_configuration.timeout).
              to eq(timeout)
          end
        end
      end

      it 'with the normalized options map' do
        allow(proof).to receive(:normalize_for_async_call).
          with(proof.options_to_attempts_hash).
          and_return(:normalized_options_to_attempts)
        proof.save!
        expect(CollectiveProofAttemptWorker).
          to have_received(:perform_async).
          with(Theorem.to_s, theorem.id, :normalized_options_to_attempts)
      end
    end
  end
end
