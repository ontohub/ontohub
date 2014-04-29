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

    context "files" do
      before { get :files, repository_id: repository.to_param }
      it { should respond_with :success }
      it { should render_template :files }
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
            post :create, repository_id: repository.to_param, upload_file: {
              target_directory: 'my_dir',
              target_filename:  'my_file',
              message: 'commit message',
              file:    Rack::Test::UploadedFile.new(Rails.root.join('test','fixtures','ontologies','owl','pizza.owl'),'image/jpg')
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
  end

end
