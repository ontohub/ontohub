require 'spec_helper'

describe RepositoriesController do
  context 'deleting a repository' do
    let(:ontology){ create :ontology }
    let(:repository){ ontology.repository }
    let(:user){ create(:permission, role: 'owner', item: repository).subject }

    context 'signed in' do
      before { sign_in user }

      context 'successful deletion' do
        before { delete :destroy, id: repository.to_param }

        it{ should respond_with :found }
        it{ response.should redirect_to Repository }
      end

      context 'unsuccessful deletion' do
        before do
          importing_repository = create :repository
          importing = create :ontology, repository: importing_repository
          create :import_mapping, target: importing, source: ontology
          delete :destroy, id: repository.to_param
        end

        it{ should set_the_flash.to(/is imported/) }
        it{ should respond_with :found }
        it{ response.should redirect_to repository }
      end
    end
  end

  context 'Repository instance' do
    render_views

    let!(:repository) { create :repository }

    context 'on GET to index' do
      before { get :index }

      it { should respond_with :success }
      it { should render_template :index }
      it { should render_template 'repositories/_repository' }
    end

    context 'on GET to show' do
      before { get :show, id: repository.path }

      it { should respond_with :success }
      it { should render_template :show }
    end

  end

end
