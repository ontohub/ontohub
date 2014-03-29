require 'spec_helper'

describe RepositoriesController do

  describe 'deleting a repository' do
    let(:ontology){ create :ontology }
    let(:repository){ ontology.repository }
    let(:user){ create(:permission, role: 'owner', item: repository).subject }

    context 'signed in' do
      before do
        sign_in user
      end

      context 'successful deletion' do
        before do
          delete :destroy, id: repository.to_param
        end

        it{ should respond_with :found }
        it{ response.should redirect_to Repository }
      end

      context 'unsuccessful deletion' do
        before do
          importing_repository = create :repository
          importing = create :ontology, repository: importing_repository
          create :import_link, target: importing, source: ontology
          delete :destroy, id: repository.to_param
        end

        it{ should set_the_flash.to(/is imported/) }
        it{ should respond_with :found }
        it{ response.should redirect_to repository }
      end
    end
  end

end
