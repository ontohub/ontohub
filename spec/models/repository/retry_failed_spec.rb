require 'spec_helper'

describe Repository do

  describe 'failed ontology' do
    let(:ontology_version){ create :ontology_version }
    let(:ontology){ ontology_version.ontology }
    let(:repository){ ontology.repository }

    before {
      ontology.versions.last.send :update_state!, :failed
      OntologyParsingWorker.jobs.clear

      repository.ontologies.retry_failed
      repository.reload

      ontology.reload
    }

    it { OntologyParsingWorker.jobs.size.should == 1 }
    it { ontology.state.should == 'pending' }
  end

end
