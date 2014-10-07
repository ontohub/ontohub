require 'spec_helper'

describe FilesController do

  describe 'iri ontology route' do
    let!(:dist_ontology){ create :heterogeneous_ontology }
    let!(:repository){ dist_ontology.repository }
    let!(:do_child){ dist_ontology.children.first }

    before do
      @repository_file = 'repository_file'
      request.stub(:accepts) { [Mime::HTML] }
      @repository_file.stub(:ontologies) { [dist_ontology] }
      RepositoryFile.stub(:find_with_path) { @repository_file }
      @request.query_string = do_child.name
      get :show, repository_id: repository.path, path: dist_ontology.name
    end

    after do
      RepositoryFile.unstub(:find_with_path)
      request.unstub(:accepts)
      @repository_file.unstub(:ontologies)
    end

    context 'should allow us to get to a do-child' do
      it { should respond_with :redirect }
      it { should redirect_to repository_ontology_path(repository, do_child) }
    end

  end

  describe "repository" do
    let!(:repository){ create :repository }

    context "files" do
      before do
        @repository_file = 'repository_file'
        @repository_file.stub(:file?) { false }
        RepositoryFile.stub(:find_with_path) { @repository_file }
        get :show, repository_id: repository.to_param
      end

      after do
        RepositoryFile.unstub(:find_with_path)
        @repository_file.unstub(:file?)
      end

      it { should respond_with :success }
      it { should render_template :show }
    end

    context "signed in with write access" do
      let(:user){ create(:permission, item: repository).subject }
      before { sign_in user }

      context "new" do
        before { get :new, repository_id: repository.to_param }
        it { should respond_with :success }
      end

      context "create" do
        context "without file" do
          before { post :create, repository_id: repository.to_param }
          it { should respond_with :success }
        end

        context "with file" do
          before {
            post :create, repository_id: repository.to_param, repository_file: {
              target_directory: 'my_dir',
              target_filename:  'my_file',
              message: 'commit message',
              temp_file: Rack::Test::UploadedFile.new(Rails.root.join('test','fixtures','ontologies','owl','pizza.owl'),'image/jpg')
            }
          }
          it { should respond_with :redirect }
        end
      end

      context "update" do

        context "with existing file" do
          let(:filepath)     { "existing-file" }
          let(:tmp_filepath) { Rails.root.join('tmp', filepath) }
          let(:message)      { "message" }

          before do
            FileUtils.rm_rf(tmp_filepath)
            File.open(tmp_filepath, 'w+') { |f| f.write("unchanged") }

            repository.save_file_only(tmp_filepath, filepath, message, user)
          end

          context "without validation error" do
            before do
              post :update,
                repository_id: repository.to_param,
                path: filepath,
                message: message,
                content: "changed"
            end

            it { should respond_with :found }
            it "should not show an error" do
              expect(flash[:error]).to be_nil
            end
            it "should show a success message" do
              expect(flash[:success]).not_to be_nil
            end
          end

          context "with validation error" do
            before do
              post :update,
                repository_id: repository.to_param,
                path: filepath,
                content: "changed"
            end

            it { should respond_with :success }
            it "should set an error message for the message field" do
              expect { flash[:error].messages[:message] }.not_to be_nil
            end
            it "should not show a success message" do
              expect(flash[:success]).to be_nil
            end
          end
        end

        context "with non-existent file" do
          let(:filepath) { "non-existent-file" }
          before do
            post :update,
              repository_id: repository.to_param,
              path: filepath,
              message: "message",
              content: "changed"
          end

          it { should respond_with :found }
          it "should not show an error" do
            expect(flash[:error]).to be_nil
          end
          it "should show a success message" do
            expect(flash[:success]).not_to be_nil
          end
          it "should have added a file" do
            expect(repository.path_exists? filepath).to be_true
          end
          it "should actually not have added a file" do
            pending "this should be another controller action"
          end
        end
      end
    end

    context "signed in, on mirror repository" do
      let(:user){ create(:permission, item: repository).subject }
      before do
        sign_in user
        repository.source_address = 'http://some_source_address.example.com'
        repository.source_type = 'git'
        repository.save
      end

      context "new" do
        before { get :new, repository_id: repository.to_param }
        it { should respond_with :redirect }
        it { should set_the_flash.to(/not authorized/) }
      end

      context "create" do
        context "without file" do
          before { post :create, repository_id: repository.to_param }
          it { should respond_with :redirect }
          it { should set_the_flash.to(/not authorized/) }
        end

        context "with file" do
          before {
            post :create, repository_id: repository.to_param, repository_file: {
              target_directory: 'my_dir',
              target_filename:  'my_file',
              message: 'commit message',
              temp_file: Rack::Test::UploadedFile.new(Rails.root.join('test','fixtures','ontologies','owl','pizza.owl'),'image/jpg')
            }
          }
          it { should respond_with :redirect }
          it { should set_the_flash.to(/not authorized/) }
        end
      end
    end
  end

end
