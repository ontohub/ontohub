require 'test_helper'

class Repository::ImportingTest < ActiveSupport::TestCase

  DIR = Rails.root.join("test","unit")
  SCRIPT_SVN_CREATE_REPO = DIR.join("git_repository_svn_create_repo.sh").to_s
  SCRIPT_SVN_ADD_COMMITS = DIR.join("git_repository_svn_add_commits.sh").to_s

  teardown do
    @repository.destroy        if @repository
    @repository_source.destroy if @repository_source
  end

  context 'an imported repository' do
    context 'via git' do
      setup do
        @user              = FactoryGirl.create :user
        @userinfo          = {email: @user[:email], name: @user[:name]}
        @source_path       = '/tmp/ontohub/test/unit/repository/repo'
        @repository_source = GitRepository.new(@source_path)

        @commit_count = 2
        @commit_count.times do |n|
          @repository_source.commit_file(@userinfo, "(#{n})", "file-#{n}.clif", "add #{n}")
        end

        @repository = Repository.import_remote('git', @user, "file://#{@source_path}", 'local import', description: 'just an imported repo')
        
        @repository.remote_repository.clone
      end

      should 'be read_only' do
        assert false, 'Test not implemented yet' #TODO
      end

      should 'have all the commits' do
        assert_equal @commit_count, @repository.commits.size
      end

      should 'have source-type git' do
        assert_equal 'git', @repository.source_type
      end

      should 'have correct source address' do
        assert_equal "file://#{@source_path}", @repository.source_address
      end

      should 'save the ontologies in the database' do
        assert_equal @commit_count, @repository.ontologies.count
      end

      should 'save ontology versions in the database' do
        @repository.ontologies.each do |o|
          assert_equal 1, o.versions.count
        end
      end

      context 'getting synchronized' do
        setup do
          @head_oid_pre = @repository_source.head_oid
          @repository_source.commit_file(@userinfo, '(and 0 0)', 'file-0.clif', 'change 0')
          @commit_count.times do |n|
            m = n+@commit_count
            @repository_source.commit_file(@userinfo, "(#{m})", "file-#{m}.clif", "add #{m}")
          end
          @head_oid_post = @repository_source.head_oid

          @repository = Repository.find_by_path(@repository.path)#reload the repository
          @repository.user = @user # it's crucial to set the user to the current user when synchronizing a repository

          @result = @repository.remote_repository.synchronize
        end

        should 'get the new changes' do
          assert_equal(2*@commit_count+1, @repository.commits.size)
          assert_equal @head_oid_pre, @result[:head_oid_pre]
          assert_equal @head_oid_post, @result[:head_oid_post]
        end

        should 'save the ontologies in the database' do
          assert_equal 2*@commit_count, @repository.ontologies.count
        end

        should 'save ontology versions in the database' do
          @repository.ontologies.each do |o|
            assert_equal(o.path == 'file-0.clif' ? 2 : 1, o.versions.count)
          end
        end
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
        @commit_count = 2
        stdin, stdout, stderr, wait_thr = Open3.popen3('bash', SCRIPT_SVN_CREATE_REPO, @path_svn, svn_server_name, svn_client_name)
        exit_status = wait_thr.value

        stdin, stdout, stderr, wait_thr = Open3.popen3('bash', SCRIPT_SVN_ADD_COMMITS, @path_svn_client, "#{@commit_count}")
        exit_status = wait_thr.value

        @user        = FactoryGirl.create :user
        @repository  = Repository.import_remote('svn', @user, @url_svn_server, 'local svn clone', description: 'just a local svn clone')
        @repository.remote_repository.clone
      end

      should 'be read_only' do
        assert false, 'Test not implemented yet' #TODO
      end

      should 'have correct source type' do
        assert_equal 'svn', @repository.source_type, 'has wrong source type'
      end

      should 'have correct source address' do
        assert_equal @url_svn_server, @repository.source_address, 'has wrong source address'
      end

      should 'be successful' do
        assert @repository.remote_repository.synchronize[:success], 'sync failed'
      end

      should 'save the ontologies in the database' do
        assert_equal @commit_count, @repository.ontologies.count
      end

      should 'save ontology versions in the database' do
        @repository.ontologies.each do |o|
          assert_equal 1, o.versions.count
        end
      end
    end
  end
end
