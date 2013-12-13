require 'spec_helper'

describe OntologiesController do

  describe 'failed ontology' do
    let(:ontology_version){ create :ontology_version }
    let(:ontology){ ontology_version.ontology }
    let(:repository){ ontology.repository }
    let(:user){ create(:permission, role: 'owner', item: repository).subject }

    before do
      OntologyVersion.stubs(:retry_failed).once
      sign_in user
    end

    describe 'on collection' do
      before do
        post :retry_failed, repository_id: repository.to_param
      end

      it{ response.should redirect_to [repository, :ontologies] }
    end

    describe 'on member' do
      before do
        post :retry_failed, repository_id: repository.to_param, id: ontology.id
      end

      it{ response.should redirect_to [repository, ontology, :ontology_versions] }
    end

  end

end
