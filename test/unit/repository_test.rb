require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase

  DIR = File.dirname(__FILE__)
  SCRIPT_SVN_CREATE_REPO = "#{DIR}/git_repository_svn_create_repo.sh"
  SCRIPT_SVN_ADD_COMMITS = "#{DIR}/git_repository_svn_add_commits.sh"
  
  should have_many :ontologies
  should have_many :permissions

  context "a repository" do
    setup do
      @user       = FactoryGirl.create :user
      @repository = FactoryGirl.create :repository, user: @user
    end

    teardown do
      @repository.destroy
    end

    context 'with a reserved name' do
      should 'not be valid' do
        repository = FactoryGirl.build :repository, user: @user, name: 'repositories'
        assert repository.invalid?
        assert repository.errors[:name].any?
      end
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

      context "that doesn't exist" do
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

        teardown do
          @repository.destroy
        end

        should 'create a new ontology version' do
          ontology = @repository.ontologies.where(basepath: File.real_basepath(@target_path)).first!
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

      teardown do
        @repository.destroy
      end

      should 'list files and directories in the directories' do
        assert_equal @repository.path_info, @repository.path_info('/')
        %w{/ folder1 folder2}.each do |folder|
          assert_equal :dir, @repository.path_info(folder)[:type]
        end
        assert_equal 4, @repository.path_info('/')[:entries].size
        assert_equal 2, @repository.path_info('folder1')[:entries].size
        assert_equal 1, @repository.path_info('folder2')[:entries].size

        path_infos_entries = @repository.path_info('/')[:entries]
        assert_equal 4, path_infos_entries.size

        selected_entry = path_infos_entries["folder1"]
        assert_equal 1, selected_entry.size
        selected_entry[0][:ontology] = !selected_entry[0][:ontology].nil?
        assert_equal [{:type=>:dir, :name=>"folder1", :path=>"folder1", :index=>0, :ontology => false}], selected_entry

        selected_entry = path_infos_entries["inroot2"]
        assert_equal 2, selected_entry.size
        selected_entry[0][:ontology] = !selected_entry[0][:ontology].nil?
        selected_entry[1][:ontology] = !selected_entry[1][:ontology].nil?
        assert_equal [
                {:type=>:file, :name=>"inroot2.clf", :path=>"inroot2.clf", :index=>3, :ontology => true},
                {:type=>:file, :name=>"inroot2.clif", :path=>"inroot2.clif", :index=>4, :ontology => true}
              ], selected_entry


        path_infos_entries = @repository.path_info('folder2')[:entries]
        assert_equal 1, path_infos_entries.size
        selected_entry = path_infos_entries["file3"]
        selected_entry[0][:ontology] = !selected_entry[0][:ontology].nil?
        assert_equal([{:type=>:file, :name=>"file3.clf", :path=>"folder2/file3.clf", :index=>0, :ontology => true}], selected_entry)
      end

      should 'list files with given basename' do
        expected = {
          type: :file_base,
          entry: {:type=>:file, :name=>"inroot1.clif", :path=>"inroot1.clif"}
        }
        assert_equal expected, @repository.path_info('inroot1')

        expected = {
          type: :file_base_ambiguous,
          entries: [
              {:type=>:file, :name=>"inroot2.clf", :path=>"inroot2.clf"},
              {:type=>:file, :name=>"inroot2.clif", :path=>"inroot2.clif"}
            ]
        }
        assert_equal expected, @repository.path_info('inroot2')
      end

      should 'have type file on exact filename' do
        @files.each do |path, content|
          assert_equal :file, @repository.path_info(path)[:type]
          assert_equal path.split('/')[-1], @repository.path_info(path)[:file][:name]
          assert_equal content.size, @repository.path_info(path)[:file][:size]
          assert_equal content, @repository.path_info(path)[:file][:content]
        end
      end

      should 'be nil on non-existent file/folder' do
        assert_nil @repository.path_info('dolfer1')
      end
    end
  end

  context 'an imported repository' do
    context 'via git' do
      setup do
        @user              = FactoryGirl.create :user
        @userinfo          = {email: @user[:email], name: @user[:name]}
        @source_path       = '/tmp/ontohub/test/unit/repository/repo'
        @repository_source = GitRepository.new(@source_path)

        @commit_count = 5
        @commit_count.times do |n|
          @repository_source.commit_file(@userinfo, "content #{n}", "file-#{n}", "message #{n}")
        end

        @repository = Repository.import_from_git(@user, "file://#{@source_path}", 'local import', description: 'just an imported repo')
      end

      teardown do
        @repository_source.destroy
        @repository.destroy
      end

      should 'be read_only' do
        assert false #TODO
      end

      should 'have all the commits' do
        assert_equal @commit_count, @repository.commits.size
      end

      should 'have source-type git' do
        assert_equal Repository::SourceTypes::GIT, @repository.source_type
      end

      should 'have correct source address' do
        assert_equal "file://#{@source_path}", @repository.source_address
      end

      should 'get the new changes' do
        head_oid_pre = @repository_source.head_oid
        @commit_count.times do |n|
          @repository_source.commit_file(@userinfo, "content #{n+@commit_count}", "file-#{n+@commit_count}", "message #{n+@commit_count}")
        end
        head_oid_post = @repository_source.head_oid

        result = @repository.sync

        assert_equal(2*@commit_count, @repository.commits.size)
        assert_equal head_oid_pre, result[:head_oid_pre]
        assert_equal head_oid_post, result[:head_oid_post]
      end
    end

    context 'via svn' do
      setup do
        @path_svn = '/tmp/ontohub/test/unit/git/svn'
        FileUtils.rmtree(@path_svn) if File.exists?(@path_svn)
        svn_server_name = 'server'
        svn_client_name = 'client'
        @url_svn_server = "file://#{@path_svn}/#{svn_server_name}"
        @path_svn_client = "#{@path_svn}/#{svn_client_name}"
        @commit_count = 5
        stdin, stdout, stderr, wait_thr = Open3.popen3('bash', SCRIPT_SVN_CREATE_REPO, @path_svn, svn_server_name, svn_client_name)
        exit_status = wait_thr.value

        stdin, stdout, stderr, wait_thr = Open3.popen3('bash', SCRIPT_SVN_ADD_COMMITS, @path_svn_client, "#{@commit_count}")
        exit_status = wait_thr.value

        @user        = FactoryGirl.create :user
        @repository  = Repository.import_from_svn(@user, @url_svn_server, 'local svn clone', description: 'just a local svn clone')
      end

      teardown do
        @repository.destroy
      end

      should 'be read_only' do
        assert false #TODO
      end

      should 'have correct source type' do
        assert_equal Repository::SourceTypes::SVN, @repository.source_type, 'has wrong source type'
      end

      should 'have correct source address' do
        assert_equal @url_svn_server, @repository.source_address, 'has wrong source address'
      end

      should 'be successful' do
        assert @repository.sync[:success], 'sync failed'
      end
    end
  end
end
