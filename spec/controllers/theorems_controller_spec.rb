require 'spec_helper'

describe TheoremsController do
  let!(:theorem) { create :theorem }
  let!(:ontology) { theorem.ontology }
  let!(:repository) { ontology.repository }

  context 'signed in with read access' do
    let(:user) { create(:permission, item: repository).subject }
    before { sign_in user }

    context 'index' do
      before do
        get :index,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param
      end

      it { should respond_with :success }
      it { should render_template :index }
    end

    context 'show' do
      before do
        get :show,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param,
          id: theorem.to_param
      end
      it { should respond_with :success }
      it { should render_template :show }
    end
  end

  context 'signed in without read access' do
    let(:user) { create(:user) }
    before do
      repository.access = 'private_rw'
      repository.save!
      sign_in user
    end

    context 'index' do
      before do
        get :index,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param
      end

      it { should respond_with :found }

      it 'set the flash/alert' do
        expect(flash[:alert]).to match(/not authorized/)
      end

      it 'redirect to the root path' do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'show' do
      before do
        get :show,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param,
          id: theorem.to_param
      end
      it { should respond_with :found }

      it 'set the flash/alert' do
        expect(flash[:alert]).to match(/not authorized/)
      end

      it 'redirect to the root path' do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  context 'not signed in' do
    context 'index' do
      before do
        get :index,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param
      end

      it { should respond_with :success }
      it { should render_template :index }
    end

    context 'show' do
      before do
        get :show,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param,
          id: theorem.to_param
      end
      it { should respond_with :success }
      it { should render_template :show }
    end
  end
end
