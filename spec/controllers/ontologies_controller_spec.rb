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

  describe 'deleting an ontology' do
    let(:ontology){ create :ontology }
    let(:repository){ ontology.repository }
    let(:user){ create(:permission, role: 'owner', item: repository).subject }

    context 'signed in' do
      before do
        sign_in user
      end

      context 'successful deletion' do
        before do
          delete :destroy, repository_id: repository.to_param, id: ontology.id
        end

        it{ should respond_with :found }
        it 'should redirect to ontologies-index of repository' do
          expect(response).to redirect_to([repository, :ontologies])
        end
      end

      context 'unsuccessful deletion' do
        before do
          importing = create :ontology
          create :import_link, target: importing, source: ontology
          delete :destroy, repository_id: repository.to_param, id: ontology.id
        end

        it{ should set_the_flash.to(/is imported/) }
        it{ should respond_with :found }
        it{ response.should redirect_to [repository, ontology] }
      end
    end
  end

end
