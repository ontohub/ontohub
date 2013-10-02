require 'spec_helper'

describe FilesController do

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
