require 'spec_helper'

describe CollectiveProofAttemptWorker do
  context 'perform_async' do
    let(:args) { %i(some arguments) }
    before do
      allow(CollectiveProofAttemptWorker).
        to receive(:perform_async_on_queue)
    end

    it 'call perform_async_on_queue with hets' do
      CollectiveProofAttemptWorker.perform_async(*args)
      expect(CollectiveProofAttemptWorker).
        to have_received(:perform_async_on_queue).
        with('hets', *args)
    end
  end

  context 'perform' do
    let(:cpa_worker) { CollectiveProofAttemptWorker.new }
    let(:cpa) { Object.new } # A spy. For Rspec 3, use spy(:something)
    before do
      allow(CollectiveProofAttempt).to receive(:new).and_return(cpa)
      allow(cpa).to receive(:run)
    end

    let(:proof_attempt) { create :proof_attempt }
    let(:theorem) { proof_attempt.theorem }
    let(:ontology_version) { theorem.ontology.current_version }
    let(:prove_options) do
      Hets::ProveOptions.new('prover' => proof_attempt.prover)
    end
    let(:normalized_options_to_attempts_hash) do
      {prove_options.to_json => [proof_attempt.id]}
    end

    it 'retrieve_options_and_attempts fetches/builds the correct objects' do
      options_and_attempts =
        cpa_worker.send(:retrieve_options_and_attempts,
                        normalized_options_to_attempts_hash)
      keys = options_and_attempts.keys
      values = options_and_attempts.values

      # We can't compare equality of the hashes here, because the keys are
      # equal, but not the same object in the memory. This makes ruby say that
      # the hashes are inequal.
      expect([keys, values]).
        to eq([[Hets::ProveOptions.from_json(prove_options.to_json)],
               [[proof_attempt]]])
    end

    context 'with stubbed retrieve_options_and_attempts' do
      before do
        allow(cpa_worker).
          to receive(:retrieve_options_and_attempts).
          with(normalized_options_to_attempts_hash).
          and_return(:options_to_attempts_hash)
      end

      context 'on the theorem' do
        before do
          cpa_worker.perform(theorem.class.to_s, theorem.id,
                             normalized_options_to_attempts_hash)
        end

        it 'create a CollectiveProofAttempt' do
          expect(CollectiveProofAttempt).
            to have_received(:new).
            with(theorem, :options_to_attempts_hash)
        end

        it 'call run' do
          expect(cpa).to have_received(:run)
        end
      end

      context 'on the ontology_version' do
        before do
          cpa_worker.perform(ontology_version.class.to_s,
                             ontology_version.id,
                             normalized_options_to_attempts_hash)
        end

        it 'create a CollectiveProofAttempt' do
          expect(CollectiveProofAttempt).
            to have_received(:new).
            with(ontology_version, :options_to_attempts_hash)
        end

        it 'call run' do
          expect(cpa).to have_received(:run)
        end
      end
    end
  end
end
