require 'spec_helper'

describe TimeoutWorker do

  context 'when a timeout is not set' do

    let(:worker) { TimeoutWorker.new }

    before do
      Settings.stub(:ontology_parse_timeout) { nil }
    end

    after do
      Settings.unstub(:ontology_parse_timeout)
    end

    it 'will complain with an error' do
      expect { TimeoutWorker.timeout_limit }.to raise_error(TimeoutWorker::TimeOutNotSetError)
    end

  end

  context 'when a timeout has been set' do
    let(:worker) { TimeoutWorker.new }
    let(:ontology_version) { create :ontology_version }
    let(:ontology) { ontology_version.ontology }

    context 'when the state is processing' do
      let(:offset_hours) { Settings.ontology_parse_timeout }

      before do
        worker.perform(ontology_version.id)
        ontology_version.reload
      end

      it 'will set the state of the ontology version to failed' do
        expect(ontology_version.state).to eq('failed')
      end

      it 'will set the error message of the ontology version accordingly' do
        expect(ontology_version.last_error).to include('The job reached the timeout limit')
      end

      it 'will set the state of the ontology to failed' do
        expect(ontology.state).to eq('failed')
      end

    end

    context 'when the version is done' do
      let(:ontology_version) { create :ontology_version, state: 'done' }

      it 'will not touch the state of the ontology_version' do
        expect { worker.perform(ontology_version.id) }.
          to_not change(ontology_version, :state)
      end

      it 'will not touch the state of the ontology' do
        expect { worker.perform(ontology_version.id) }.
          to_not change(ontology, :state)
      end

    end

    context 'when the version is failed' do
      let(:ontology_version) { create :ontology_version, state: 'failed' }

      it 'will not touch the state of the ontology_version' do
        expect { worker.perform(ontology_version.id) }.
          to_not change(ontology_version, :state)
      end

      it 'will not touch the state of the ontology' do
        expect { worker.perform(ontology_version.id) }.
          to_not change(ontology, :state)
      end

    end

  end

end
