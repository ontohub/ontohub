require 'spec_helper'

# We try to be explicit when using sidekiq
# testing modes. However inline! is the default
describe OntologyBatchParseWorker do
  setup_hets

  let(:balancer) { ConcurrencyBalancer.new }

  context 'using the sequential queue' do
    let(:ontology) { create :single_unparsed_ontology}
    let(:version) { ontology.versions.last }

    before do
      begin
        balancer.mark_as_finished_processing(ontology.iri)
      rescue ConcurrencyBalancer::UnmarkedProcessingError
      end
      balancer.mark_as_processing_or_complain(ontology.iri)
      OntologyVersion.any_instance.stubs(:raw_path!).returns(
        ontology_file('clif/sequential_parse'))
      stub_hets_for('clif/sequential_parse.clif')
    end

    after do
      balancer.mark_as_finished_processing(ontology.iri)
      OntologyVersion.any_instance.unstub(:raw_path!)
    end

    context 'exceeding the parallel try count of an already marked iri job' do
      it 'should put the correct job in the sequential queue' do
        optioned_versions = [[version.id, {"fast_parse" => version.fast_parse}]]
        OntologyBatchParseWorker.new.perform(
          optioned_versions, try_count: ConcurrencyBalancer::MAX_TRIES)
        expect(SequentialOntologyBatchParseWorker.jobs.first['args']).to eq([optioned_versions])
      end
    end

    context 'not exceeding the parallel try count of an already marked iri job' do
      it 'should put the correct job in the queue once again' do
        optioned_versions = [[version.id, {"fast_parse" => version.fast_parse}]]
        OntologyBatchParseWorker.new.perform(
          optioned_versions, try_count: ConcurrencyBalancer::MAX_TRIES-1)
        expect(OntologyBatchParseWorker.jobs.first['args']).to eq([
          nil, optioned_versions,
          "try_count" => ConcurrencyBalancer::MAX_TRIES])
      end
    end

    context 'working with the priority queue' do
      it 'should place a job on the priority-queue, when called with priority mode' do
        OntologyBatchParseWorker.perform_async_with_priority(true, [])
        expect(OntologyBatchParseWorker.jobs.first["queue"]).
               to eq('priority_push')
      end

      it 'should place a job on the hets-queue, when called without priority mode' do
        OntologyBatchParseWorker.perform_async_with_priority(false, [])
        expect(OntologyBatchParseWorker.jobs.first["queue"]).
               to eq('hets')
      end
    end

    context 'and when a new job needs to be scheduled' do

      before do
        allow_any_instance_of(OntologyVersion).to receive(:parse).
          and_raise(ConcurrencyBalancer::AlreadyProcessingError)
      end

      it 'should be placed in priority if it started this way' do
        optioned_versions = [[version.id, {"fast_parse" => version.fast_parse}]]
        OntologyBatchParseWorker.new.
          perform('priority_push',
                  optioned_versions,
                  try_count: ConcurrencyBalancer::MAX_TRIES-1)
        expect(OntologyBatchParseWorker.jobs.first['queue']).
          to eq('priority_push')
      end

      it 'should not be placed in priority if it did not start this way' do
        optioned_versions = [[version.id, {"fast_parse" => version.fast_parse}]]
        OntologyBatchParseWorker.new.
          perform(optioned_versions, try_count: ConcurrencyBalancer::MAX_TRIES-1)
        expect(OntologyBatchParseWorker.jobs.first['queue']).
          to eq('hets')
      end
    end

  end

end
