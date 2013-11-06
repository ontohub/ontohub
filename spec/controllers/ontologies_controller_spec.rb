require 'spec_helper'

describe OntologiesController do

  describe 'failed ontology' do
    let(:ontology_version){ create :ontology_version }
    let(:ontology){ ontology_version.ontology }
    let(:repository){ ontology.repository }

    before do
      OntologyVersion.stubs(:retry_failed).once
      post :retry_failed, repository_id: repository.to_param
    end

    it{ respond_with :redirect }
  end

end
