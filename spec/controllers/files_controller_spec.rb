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
              temp_file: Rack::Test::UploadedFile.new(
                ontology_file('owl/pizza.owl'),'image/jpg')
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
            tmpfile = Tempfile.new('repository_test')
            tmpfile.write('unchanged')
            tmpfile.close

            repository.save_file(tmpfile, filepath, message, user, do_parse: false)
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
            it "should show a success message" do
              expect(flash[:success]).not_to be(nil)
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
            it "should not show a success message" do
              expect(flash[:success]).to be(nil)
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
            expect(flash[:error]).to be(nil)
          end
          it "should show a success message" do
            expect(flash[:success]).not_to be(nil)
          end
          it "should have added a file" do
            expect(repository.path_exists? filepath).to be(true)
          end
          it "should actually not have added a file" do
            skip "this should be another controller action"
          end
        end
      end

      context "destroy" do
        let(:filepath)     { "existing-file" }
        let(:tmp_filepath) { Rails.root.join('tmp', filepath) }
        let(:message)      { "message" }

        before do
          tmpfile = Tempfile.new('repository_test')
          tmpfile.write('unchanged')
          tmpfile.close

          repository.save_file(tmpfile, filepath, message, user, do_parse: false)
        end

        before do
          delete :destroy, repository_id: repository.to_param, path: filepath
        end

        it { should respond_with :found }
        it "should not show an error" do
          expect(flash[:error]).to be_nil
        end
        it "should show a success message" do
          expect(flash[:success]).not_to be_nil
        end
        it 'sets the flash' do
          expect(flash[:success]).to match(/success/i)
        end
      end
    end

    context "signed in, on mirror repository" do
      let(:repository) { create :repository_with_empty_remote }
      let(:user){ create(:permission, item: repository).subject }

      context "new" do
        before { get :new, repository_id: repository.to_param }
        it { should respond_with :redirect }

        it 'sets the flash' do
          expect(flash[:alert]).to match(/not authorized/)
        end
      end

      context "create" do
        context "without file" do
          before { post :create, repository_id: repository.to_param }
          it { should respond_with :redirect }

          it 'sets the flash' do
            expect(flash[:alert]).to match(/not authorized/)
          end
        end

        context "with file" do
          before {
            post :create, repository_id: repository.to_param, repository_file: {
              target_directory: 'my_dir',
              target_filename:  'my_file',
              message: 'commit message',
              temp_file: Rack::Test::UploadedFile.new(
                ontology_file('owl/pizza.owl'),'image/jpg')
            }
          }
          it { should respond_with :redirect }

          it 'sets the flash' do
            expect(flash[:alert]).to match(/not authorized/)
          end
        end
      end
    end
  end

end
