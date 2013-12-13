require 'spec_helper'

describe FilesController do

  describe 'iri ontology route' do
    let!(:dist_ontology){ create :heterogeneous_ontology }
    let!(:repository){ dist_ontology.repository }
    let!(:do_child){ dist_ontology.children.first }

    before do
      Repository.any_instance.stubs(:path_info).returns({
        type: :file_base,
        entry: {path: dist_ontology.basepath }
      })
      @request.query_string = do_child.name
      get :files, repository_id: repository.path, path: dist_ontology.name
    end

    after do
      Repository.any_instance.unstub(:path_info)
    end

    context 'should allow us to get to a do-child' do
      it { should respond_with :redirect }
      it { should redirect_to repository_ontology_path(repository, do_child) }
    end

  end

  describe "repository" do
    let!(:repository){ create :repository }

    describe "files" do
      before { get :files, repository_id: repository.to_param }
      it { should respond_with :success }
      it { should render_template :files }
    end


    describe "signed in with write access" do
      let(:user){ create(:permission, item: repository).subject }
      before { sign_in user }

      describe "new" do
        before { get :new, repository_id: repository.to_param }
        it { should respond_with :success }
      end

      describe "create" do
        describe "without file" do
          before { post :create, repository_id: repository.to_param }
          it { should respond_with :success }
        end

        describe "with file" do
          before {
            post :create, repository_id: repository.to_param, upload_file: {
              path:    'my_path',
              message: 'commit message',
              file:    Rack::Test::UploadedFile.new(Rails.root.join('test','fixtures','ontologies','owl','pizza.owl'),'image/jpg')
            }
          }
          it { should respond_with :redirect }
        end
      end
    end
  end

end
