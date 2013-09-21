require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase
  
  should have_many :ontologies
  should have_many :permissions

  context "a repository" do
    setup do
      @user       = FactoryGirl.create :user
      @repository = FactoryGirl.create :repository, user: @user
    end

    context 'creating a permission' do
      setup do
        assert_not_nil @permission = @repository.permissions.first
      end
      
      should 'with subject' do
        assert_equal @user, @permission.subject
      end
      
      should 'with role owner' do
        assert_equal 'owner', @permission.role
      end
    end

    context 'saving a file' do
      setup do 
        @file_path = '/tmp/ontohub/test/git_repository/save_file.txt'
        @target_path = 'save_file.clif'
        @message = 'test message'
        @content = "(Cat x)\n"

        # create directory if it doesn't exist
        dir = File.dirname(@file_path)
        unless File.directory?(dir)
          FileUtils.mkdir_p(dir)
        end
        
        # create file
        tmpfile = File.open(@file_path, 'w')
        tmpfile.puts(@content)
        tmpfile.close
      end

      should 'not have an ontology yet' do
        assert_equal @repository.ontologies.count, 0
      end

      context 'that doesn\'t exist' do
        setup do
          OntologyVersion.any_instance.expects(:parse_async).once
          @version = @repository.save_file(@file_path, @target_path, @message, @user)
        end

        should 'create the file in the git repository' do
          assert @repository.git.path_exists?(@target_path)
        end

        should 'create the file with correct contents in the git repository' do
          assert_equal @content, @repository.git.get_file(@target_path)[:content]
        end

        should 'create a new ontology with a default name' do
          assert_equal @repository.ontologies.count, 1
          assert_equal @repository.ontologies.first.name, 'Save_file'
        end

        should 'create a new ontology with only one version pointing to the commit' do
          o = @repository.ontologies.first
          assert_equal o.versions.count, 1
          assert_equal o.versions.first[:commit_oid], @version.commit_oid
        end

        should 'create a new ontology with only one version belonging to the right user' do
          v = @repository.ontologies.first.versions.first
          assert_equal v.user, @user
        end
      end

      context 'that exists' do
        setup do
          OntologyVersion.any_instance.expects(:parse_async).twice
          @repository.save_file(@file_path, @target_path, @message, @user)
          
          file = File.open(@file_path, 'w')
          file.puts("#{@content}\n#{@content}")
          file.close
          
          @repository.save_file(@file_path, @target_path, @message, @user)
        end

        should 'create a new ontology version' do
          ontology = @repository.ontologies.where(path: @target_path).first!
          assert_equal 2, ontology.versions.count
        end
      end
    end

    context 'browsing the repository' do
      setup do
        @files = {
          'inroot1.clif' => "(In1 Root)\n",
          'inroot2.clf' => "(In2 Root Too)\n",
          'inroot2.clif' => "(In2 Root Too2)\n",
          'folder1/file1.clif' => "(In Folder)\n",
          'folder1/file2.clf' => "(In2 Folder Too)\n",
          'folder2/file3.clf' => "(In2 Folder Again)\n"
        }
        @message = 'test message'
        @file_path_prefix = '/tmp/ontohub/test/git_repository/'
        @iri_prefix = 'http://localhost/repo_name/'
        @files.each do | path, content |
          file_path = "#{@file_path_prefix}#{path}"

          # create directory if it doesn't exist
          dir = File.dirname(file_path)
          unless File.directory?(dir)
            FileUtils.mkdir_p(dir)
          end
          
          # create file
          tmpfile = File.open(file_path, 'w')
          tmpfile.puts(content)
          tmpfile.close
          
          OntologyVersion.any_instance.expects(:parse_async).once
          @repository.save_file(file_path, path, @message, @user, "#{@iri_prefix}#{file_path}")
        end
      end

      should 'list files and directories in the directories' do
        assert_equal @repository.path_type, @repository.path_type('/')
        %w{/ folder1 folder2}.each do |folder|
          assert_equal :dir, @repository.path_type(folder)[:type]
        end
        assert_equal 5, @repository.path_type('/')[:entries].size
        assert_equal 2, @repository.path_type('folder1')[:entries].size
        assert_equal 1, @repository.path_type('folder2')[:entries].size
      end

      should 'list files with given basename' do
        expected = {
          type: :file_base,
          entries: [{:type=>:file, :name=>"inroot1.clif", :path=>"inroot1.clif"}]
        }
        assert_equal expected, @repository.path_type('inroot1')

        expected = {
          type: :file_base,
          entries: [
              {:type=>:file, :name=>"inroot2.clf", :path=>"inroot2.clf"},
              {:type=>:file, :name=>"inroot2.clif", :path=>"inroot2.clif"}
            ]
        }
        assert_equal expected, @repository.path_type('inroot2')
      end

      should 'have type raw on exact filename' do
        @files.each do |path, content|
          assert_equal :raw, @repository.path_type(path)[:type]
          assert_equal path.split('/')[-1], @repository.path_type(path)[:file][:name]
          assert_equal content.size, @repository.path_type(path)[:file][:size]
          assert_equal content, @repository.path_type(path)[:file][:content]
        end
      end
    end
  end
end
