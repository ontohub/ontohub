require 'spec_helper'

describe OntologiesController do

  context 'failed ontology' do
    let(:ontology_version){ create :ontology_version }
    let(:ontology){ ontology_version.ontology }
    let(:repository){ ontology.repository }
    let(:user){ create(:permission, role: 'owner', item: repository).subject }

    before do
      OntologyVersion.stubs(:retry_failed).once
      sign_in user
    end

    context 'on collection' do
      before { post :retry_failed, repository_id: repository.to_param }

      it{ response.should redirect_to [repository, :ontologies] }
    end

    context 'on member' do
      before do
        post :retry_failed, repository_id: repository.to_param, id: ontology.id
      end

      it{ response.should redirect_to [repository, ontology, :ontology_versions] }
    end

  end

  context 'deleting an ontology' do
    let(:ontology){ create :ontology }
    let(:repository){ ontology.repository }
    let(:user){ create(:permission, role: 'owner', item: repository).subject }

    context 'signed in' do
      before do
        sign_in user

        allow_any_instance_of(Repository).
          to receive(:delete_file).and_return('0'*40)
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
          create :import_mapping, target: importing, source: ontology
          delete :destroy, repository_id: repository.to_param, id: ontology.id
        end

        it{ should set_the_flash.to(/is imported/) }
        it{ should respond_with :found }
        it{ response.should redirect_to [repository, ontology] }
      end
    end
  end

  context 'Ontology Instance' do
    let(:ontology) { create :single_ontology, state: 'done' }
    let(:repository) { ontology.repository }
    let(:user) { create :user }
    before { 2.times { create :symbol, ontology: ontology } }

    context 'on GET to index' do
      context 'for a repository' do
        before { get :index, repository_id: repository.to_param }

        it { should respond_with :success }
        it { should render_template :index_repository }
      end
      context 'for the whole website' do
        before { get :index }
        it { should respond_with :success }
        it { should render_template :index_global }
      end
    end

    context 'on GET to show' do
      before { OntologyMember::Symbol.delete_all }

      context 'with format json' do
        before do
          get :show,
            repository_id: repository.to_param,
            format:        :json,
            id:            ontology.to_param
        end

        it { should respond_with :success }

        it 'respond with json content type' do
          expect(response.content_type.to_s).to eq('application/json')
        end

      end

      context 'without symbols' do
        before do
          get :show,
            repository_id: repository.to_param,
            id:            ontology.to_param
        end

        it { should respond_with :redirect }
        it do
          should redirect_to(controllers_locid_for(ontology, 'symbols;kind=Symbol'))
        end
      end

      context 'with symbol of kind Class' do
        before do
          symbol = create :symbol, ontology: ontology, kind: 'Class'
          get :show,
            repository_id: repository.to_param,
            id:            ontology.to_param
        end

        it { should respond_with :redirect }
        it do
          should redirect_to(controllers_locid_for(ontology, 'symbols;kind=Class'))
        end
      end
    end

    context 'owned by signed in user' do
      before do
        sign_in user
        repository.permissions.create! \
          role: 'owner',
          subject: user
      end

      context 'on GET to edit' do
        before do
          get :edit,
            repository_id: repository.to_param,
            id:            ontology.to_param
        end

        it { should respond_with :success }
        it { should render_template :edit }
      end

      context 'on PUT to update' do
        before do
          put :update,
            repository_id: repository.to_param,
            id:            ontology.to_param,
            name:          'foo bar'
        end

        it { should redirect_to([repository, ontology]) }
      end
    end
  end
end
