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

    let(:provers) { [] }
    let(:theorem) { create :theorem }
    let(:ontology_version) { theorem.ontology.current_version }

    context 'on the theorem' do
      before do
        cpa_worker.perform(theorem.class.to_s, theorem.id, provers)
      end

      it 'create a CollectiveProofAttempt' do
        expect(CollectiveProofAttempt).
          to have_received(:new).
          with(theorem, provers)
      end

      it 'call run' do
        expect(cpa).to have_received(:run)
      end
    end

    context 'on the ontology_version' do
      before do
        cpa_worker.perform(ontology_version.class.to_s,
                           ontology_version.id,
                           provers)
      end

      it 'create a CollectiveProofAttempt' do
        expect(CollectiveProofAttempt).
          to have_received(:new).
          with(ontology_version, provers)
      end

      it 'call run' do
        expect(cpa).to have_received(:run)
      end
    end
  end
end
