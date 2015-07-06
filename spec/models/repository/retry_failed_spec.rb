require 'spec_helper'

describe Repository do

  describe 'failed ontology' do
    let(:ontology_version){ create :ontology_version }
    let(:ontology){ ontology_version.ontology }
    let(:repository){ ontology.repository }

    before {
      ontology.versions.last.send :update_state!, :failed
      Worker.jobs.clear

      repository.ontologies.retry_failed
      repository.reload

      ontology.reload
    }

    it { expect(Worker.jobs.size).to eq(1) }
    it { expect(ontology.state).to eq('pending') }
  end

end
