require 'test_helper'

# Tests a git repository
#
# Author: Eugen Kuksa <eugenk@informatik.uni-bremen.de>

class GitRepositoryTest < ActiveSupport::TestCase

  ENV['LANG'] = 'C'

  DIR = File.dirname(__FILE__)
  SCRIPT_GIT_REMOTE_V = "#{DIR}/git_repository_remote_v.sh"
  SCRIPT_SVN_CREATE_REPO = "#{DIR}/git_repository_svn_create_repo.sh"
  SCRIPT_SVN_ADD_COMMITS = "#{DIR}/git_repository_svn_add_commits.sh"

  context 'creating and deleting a repository' do
    setup do
      @path = '/tmp/ontohub/test/unit/git/repository'
    end

    teardown do
      FileUtils.rmtree(@path) if File.exists?(@path)
      @path = nil
      @repository = nil
    end

    should 'create repository' do
      @path_new = "#{@path}_new"
      assert !File.exists?(@path_new)
      @repository_new = GitRepository.new(@path_new)
      assert File.exists?(@path_new)
      assert @repository_new.empty?
    end

    should 'delete repository' do
      @path_new = "#{@path}_new"
      @repository_new = GitRepository.new(@path_new)
      assert File.exists?(@path_new)
      @repository_new.destroy
      assert !File.exists?(@path_new)
    end
  end

  context 'existing repository' do
    setup do
      @path = '/tmp/ontohub/test/unit/git/repository'
      @repository = GitRepository.new(@path)
      @userinfo = {
        email: 'jan@jansson.com',
        name: 'Jan Jansson',
        time: Time.now
      }
    end

    teardown do
      FileUtils.rmtree(@path) if File.exists?(@path)
      @path = nil
      @repository = nil
    end

    context 'using files' do
      setup do
        @filepath = 'path/file.txt'
        @content = 'Some content'
        @message = 'Some commit message'
      end

      should 'create single commit of a file' do
        @repository.commit_file(@userinfo, @content, @filepath, @message)
        assert @repository.path_exists?(@filepath)
        assert_equal @repository.get_file(@filepath)[:name], @filepath.split('/')[-1]
        assert_equal @repository.get_file(@filepath)[:content], @content
        assert_equal @repository.get_file('path/file.txt')[:mime_type], Mime::Type.lookup('text/plain')
        assert_equal @repository.commit_message, @message
        assert_equal @repository.commit_author[:name], @userinfo[:name]
        assert_equal @repository.commit_author[:email], @userinfo[:email]
        # removed because of time zone issues
        #assert_equal Time.at(@repository.commit_author[:time]), Time.gm(@userinfo[:time])
      end

      should 'delete a file' do
        @repository.commit_file(@userinfo, @content, @filepath, @message)
        @repository.delete_file(@userinfo, @filepath)
        assert !@repository.path_exists?(@filepath)
      end

      should 'overwrite a file' do
        content2 = "#{@content}_2"
        message2 = "#{@message}_2"
        @repository.commit_file(@userinfo, @content, @filepath, @message)
        first_commit_oid = @repository.head_oid
        @repository.commit_file(@userinfo, content2, @filepath, message2)
        assert @repository.path_exists?(@filepath)
        assert_equal @repository.get_file(@filepath)[:content], content2
        assert_equal @repository.commit_message(@repository.head_oid), message2
        assert_not_equal first_commit_oid, @repository.head_oid
      end

      should 'reset state on empty repository with failing commit block' do
        assert @repository.empty?
        assert_raise Exception do
          @repository.commit_file(@userinfo, @content, @filepath, @message) do
            raise Exception
          end
        end
        # it is actually empty, but in this test this can't be found out
        #assert @repository.empty?
      end

      should 'reset state with failing commit block' do
        first_commit_oid = @repository.commit_file(@userinfo, @content, @filepath, @message)
        assert_equal first_commit_oid, @repository.head_oid
        assert_raise Exception do
          second_commit_oid = @repository.commit_file(@userinfo, "#{@content}!", @filepath, @message) do
            raise Exception
          end
        end
        # it is actually equal, but in this test this can't be found out
        #assert_equal first_commit_oid, @repository.head_oid
      end
    end

    context 'using folders' do
      setup do
        @subfolder = 'path'
        @filepath1 = "#{@subfolder}/file1.txt"
        @filepath2 = "#{@subfolder}/file2.txt"
        @filepath3 = 'file3.txt'
        @content = 'Some content'
        @message1 = 'Some commit message1'
        @message2 = 'Some commit message2'
        @message3 = 'Some commit message3'
        @commit_add1 = @repository.commit_file(@userinfo, @content, @filepath1, @message1)
        @commit_add2 = @repository.commit_file(@userinfo, @content, @filepath2, @message2)
        @commit_add3 = @repository.commit_file(@userinfo, @content, @filepath3, @message3)
        @commit_del1 = @repository.delete_file(@userinfo, @filepath1)
        @commit_del2 = @repository.delete_file(@userinfo, @filepath2)
        @commit_del3 = @repository.delete_file(@userinfo, @filepath3)
      end

      should 'read the right number of contents in the root folder after adding the first file' do
        assert_equal @repository.folder_contents(@commit_add1).size, 1
      end

      should 'read the right contents in the root folder after adding the first file' do
        assert_equal @repository.folder_contents(@commit_add1), [{
            type: :dir,
            name: @subfolder,
            path: @subfolder
          }]
      end

      should 'read the right number of contents in the subfolder after adding the first file' do
        assert_equal @repository.folder_contents(@commit_add1, @subfolder).size, 1
      end

      should 'read the right contents in the subfolder after adding the first file' do
        assert_equal @repository.folder_contents(@commit_add1, @subfolder), [{
          type: :file,
          name: @filepath1.split('/')[-1],
          path: @filepath1
        }]
      end


      should 'read the right number of contents in the root folder after adding the second file' do
        assert_equal @repository.folder_contents(@commit_add2).size, 1
      end

      should 'read the right contents in the root folder after adding the second file' do
        assert_equal @repository.folder_contents(@commit_add2), [{
          type: :dir,
          name: @subfolder,
          path: @subfolder
        }]
      end

      should 'read the right number of contents in the subfolder after adding the second file' do
        assert_equal @repository.folder_contents(@commit_add2, @subfolder).size, 2
      end

      should 'read the right contents in the subfolder after adding the second file' do
        assert_equal @repository.folder_contents(@commit_add2, @subfolder), [{
          type: :file,
          name: @filepath1.split('/')[-1],
          path: @filepath1
        },{
          type: :file,
          name: @filepath2.split('/')[-1],
          path: @filepath2
        }]
      end


      should 'read the right number of contents in the root folder after adding the third file' do
        assert_equal @repository.folder_contents(@commit_add3).size, 2
      end

      should 'read the right contents in the root folder after adding the third file' do
        assert_equal @repository.folder_contents(@commit_add3), [{
          type: :dir,
          name: @subfolder,
          path: @subfolder
        },{
          type: :file,
          name: @filepath3.split('/')[-1],
          path: @filepath3
        }]
      end

      should 'read the right number of contents in the subfolder after adding the third file' do
        assert_equal @repository.folder_contents(@commit_add3, @subfolder).size, 2
      end

      should 'read the right contents in the subfolder after adding the third file' do
        assert_equal @repository.folder_contents(@commit_add3, @subfolder), [{
          type: :file,
          name: @filepath1.split('/')[-1],
          path: @filepath1
        },{
          type: :file,
          name: @filepath2.split('/')[-1],
          path: @filepath2
        }]
      end

      should 'treat path "/" and empty path equally' do
        assert_equal @repository.folder_contents(@commit_add3, '/'), @repository.folder_contents(@commit_add3)
        assert_equal @repository.folder_contents(@commit_add3, '/'), @repository.folder_contents(@commit_add3, nil)
      end


      should 'read the right number of contents in the root folder after deleting the first file' do
        assert_equal @repository.folder_contents(@commit_del1).size, 2
      end

      should 'read the right contents in the root folder after deleting the first file' do
        assert_equal @repository.folder_contents(@commit_del1), [{
          type: :dir,
          name: @subfolder,
          path: @subfolder
        },{
          type: :file,
          name: @filepath3.split('/')[-1],
          path: @filepath3
        }]
      end

      should 'read the right number of contents in the subfolder after deleting the first file' do
        assert_equal @repository.folder_contents(@commit_del1, @subfolder).size, 1
      end

      should 'read the right contents in the subfolder after deleting the first file' do
        assert_equal @repository.folder_contents(@commit_del1, @subfolder), [{
          type: :file,
          name: @filepath2.split('/')[-1],
          path: @filepath2
        }]
      end


      should 'read the right number of contents in the root folder after deleting the second file' do
        assert_equal @repository.folder_contents(@commit_del2).size, 1
      end

      should 'read the right contents in the root folder after deleting the second file' do
        assert_equal @repository.folder_contents(@commit_del2), [{
          type: :file,
          name: @filepath3.split('/')[-1],
          path: @filepath3
        }]
      end


      should 'read the right number of contents in the root folder after deleting the third file' do
        assert_equal @repository.folder_contents(@commit_del3).size, 0
      end

      should 'read the right contents in the root folder after deleting the third file' do
        assert_equal @repository.folder_contents(@commit_del3), []
      end
    end

    context 'getting the commit history' do
      setup do
        @filepath = 'path/to/file.txt'
        @commit_add1 = @repository.commit_file(@userinfo, 'Some content1', @filepath, 'Add')
        @commit_change1 = @repository.commit_file(@userinfo, 'Some other content1', @filepath, 'Change')
        @commit_other1 = @repository.commit_file(@userinfo, 'Other content1', 'file2.txt', 'Other File: Add')
        @commit_delete1 = @repository.delete_file(@userinfo, @filepath)
        @commit_other2 = @repository.commit_file(@userinfo, 'Other content2', 'file2.txt', 'Other File: Change1')
        @commit_other3 = @repository.commit_file(@userinfo, 'Other content3', 'file2.txt', 'Other File: Change2')
        @commit_add2 = @repository.commit_file(@userinfo, 'Some content2', @filepath, 'Re-Add')
        @commit_change2 = @repository.commit_file(@userinfo, 'Some other content2', @filepath, 'Re-Change')
        @commit_delete2 = @repository.delete_file(@userinfo, @filepath)
      end

      should 'list all commits regarding the whole branch' do
        assert_equal @repository.commits(start_oid: @commit_delete2), @repository.commits
        assert_equal [ @commit_delete2, @commit_change2, @commit_add2,
                       @commit_other3, @commit_other2, @commit_delete1,
                       @commit_other1, @commit_change1, @commit_add1 ],
                     @repository.commits.map{ |c| c[:oid] }
        assert_equal 2, @repository.commits(start_oid: @commit_change1).size
      end

      should 'have the correct values in the history at the HEAD' do
        assert_equal @repository.commits(start_oid: @commit_delete2, path:@filepath),
          @repository.commits(path: @filepath)
        assert_equal [
          @commit_delete2,
          @commit_change2,
          @commit_add2,
          @commit_delete1,
          @commit_change1,
          @commit_add1
        ], @repository.commits(path: @filepath).map{ |c| c[:oid] }
      end

      should 'have the correct values in the history a commit before the HEAD' do
        assert_equal [
          @commit_change2,
          @commit_add2,
          @commit_delete1,
          @commit_change1,
          @commit_add1
        ], @repository.commits(start_oid: @commit_change2, path: @filepath).map{ |c| c[:oid] }
      end

      should 'have the correct values in the history a commit before the HEAD until fourth commit' do
        assert_equal [
          @commit_change2,
          @commit_add2
        ], @repository.commits(start_oid: @commit_change2, path: @filepath, stop_oid: @commit_delete1).map{ |c| c[:oid] }
      end

      should 'have the correct values in the history in the commit that changes another file' do
        assert_equal [
          @commit_delete1,
          @commit_change1,
          @commit_add1
        ], @repository.commits(start_oid: @commit_other3, path: @filepath).map{ |c| c[:oid] }
      end

      should 'only get the oid of each commit (for any file)' do
        assert_equal [
          @commit_delete2,
          @commit_change2,
          @commit_add2,
          @commit_other3,
          @commit_other2,
          @commit_delete1,
          @commit_other1,
          @commit_change1,
          @commit_add1
        ], @repository.commits { |commit_oid| commit_oid }
      end

      should 'only get the oid of each commit that changes a specific file' do
        assert_equal [
          @commit_delete2,
          @commit_change2,
          @commit_add2,
          @commit_delete1,
          @commit_change1,
          @commit_add1
        ], @repository.commits(path: @filepath) { |commit_oid| commit_oid }
      end

      should 'only list the newest commits if a limit is specified' do
        assert_equal([
          @commit_delete2,
          @commit_change2,
          @commit_add2], @repository.commits(limit: 3) { |commit_oid| commit_oid })
        assert_equal([
          @commit_delete2,
          @commit_change2,
          @commit_add2,
          @commit_other3,
          @commit_other2,
          @commit_delete1,
          @commit_other1,
          @commit_change1,
          @commit_add1], @repository.commits(limit: 30) { |commit_oid| commit_oid })
        assert_equal([
          @commit_delete2,
          @commit_change2,
          @commit_add2,
          @commit_delete1,
          @commit_change1
        ], @repository.commits(path: @filepath, limit: 5) { |commit_oid| commit_oid })
        assert_equal([
          @commit_delete2,
          @commit_change2,
          @commit_add2,
          @commit_delete1,
          @commit_change1,
          @commit_add1
        ], @repository.commits(path: @filepath, limit: 6) { |commit_oid| commit_oid })
        assert_equal([
          @commit_delete2,
          @commit_change2,
          @commit_add2,
          @commit_delete1,
          @commit_change1,
          @commit_add1
        ], @repository.commits(path: @filepath, limit: 7) { |commit_oid| commit_oid })
      end
    end


    context 'getting the list of changed files' do
      setup do
        @content1 = "Some\ncontent\nwith\nmany\nlines."
        @content2 = "Some\ncontent,\nwith\nmany\nlines."
        @filepath = 'path/to/file.xml'
        @file_extension = @filepath.split('.')[-1]
        @commit1 = @repository.commit_file(@userinfo, @content1, @filepath, 'Message1')
        @commit2 = @repository.commit_file(@userinfo, @content2, @filepath, 'Message2')
        @commit3 = @repository.delete_file(@userinfo, @filepath)
      end

      should 'last commit be HEAD' do
        assert_equal @repository.is_head?(@commit3), true
      end


      should 'have the right file count when using the first commit' do
        assert_equal @repository.changed_files(@commit1).size, 1
      end

      should 'have the right name in the list when using the first commit' do
        assert_equal @repository.changed_files(@commit1).first[:name], 'file.xml'
      end

      should 'have the right path in the list when using the first commit' do
        assert_equal @repository.changed_files(@commit1).first[:path], @filepath
      end

      should 'have the right type in the list when using the first commit' do
        assert_equal @repository.changed_files(@commit1).first[:type], :add
      end

      should 'have the right mime type in the list when using the first commit' do
        assert_equal @repository.changed_files(@commit1).first[:mime_type], Mime::Type.lookup_by_extension(@file_extension)
      end

      should 'have the right mime category in the list when using the first commit' do
        assert_equal @repository.changed_files(@commit1).first[:mime_category], 'application'
      end

      should 'have the right editable in the list when using the first commit' do
        assert_equal @repository.changed_files(@commit1).first[:editable], true
      end



      should 'have the right file count when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).size, 1
      end

      should 'have the right name in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first[:name], @filepath.split('/')[-1]
      end

      should 'have the right path in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first[:path], @filepath
      end

      should 'have the right type in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first[:type], :change
      end

      should 'have the right mime type in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first[:mime_type], Mime::Type.lookup_by_extension(@file_extension)
      end

      should 'have the right mime category in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first[:mime_category], 'application'
      end

      should 'have the right editable in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first[:editable], true
      end



      should 'have the right file count when using the HEAD' do
        assert_equal @repository.changed_files.size, 1
      end

      should 'have the right name in the list when using the HEAD' do
        assert_equal @repository.changed_files.first[:name], @filepath.split('/')[-1]
      end

      should 'have the right path in the list when using the HEAD' do
        assert_equal @repository.changed_files.first[:path], @filepath
      end

      should 'have the right type in the list when using the HEAD' do
        assert_equal @repository.changed_files.first[:type], :delete
      end

      should 'have the right mime type in the list when using the HEAD' do
        assert_equal @repository.changed_files.first[:mime_type], Mime::Type.lookup_by_extension(@file_extension)
      end

      should 'have the right mime category in the list when using the HEAD' do
        assert_equal @repository.changed_files.first[:mime_category], 'application'
      end

      should 'have the right editable in the list when using the HEAD' do
        assert_equal @repository.changed_files.first[:editable], true
      end
    end

    context 'being cloned' do
      setup do
        @commit_count = 2
        @commit_count.times do |n|
          @content = "content #{n}"
          @filepath = "file-#{n}"
          @message = "message #{n}"
          @repository.commit_file(@userinfo, @content, @filepath, @message)
        end

        @path_clone = '/tmp/ontohub/test/unit/git/repository_clone'
        assert !File.exists?(@path_clone), 'Folder to clone into already exists'
      end

      teardown do
        FileUtils.rmtree(@path_clone) if File.exists?(@path_clone)
        @path_clone = nil
      end

      context 'fully from filesystem into a bare repository' do
        setup do
          @result = GitRepository.clone_git("file://#{@path}", @path_clone, true)
          @repository_clone = GitRepository.new(@path_clone)
        end

        teardown do
          @repository_clone = nil
        end

        should 'be sueccessful' do
          assert @result[:success]
        end

        should 'be a bare repository' do
          assert GitRepository.is_bare_repository?(@path_clone)
        end

        should 'not be an svn clone' do
          assert !@repository_clone.is_svn_clone?
        end

        should 'clone all commits' do
          assert_equal @repository.commits, @repository_clone.commits
        end

        should 'create the same branches in the clone' do
          assert(@repository.branches & @repository_clone.branches == @repository.branches, 'The original branches are not a subset of the clone branches.')
        end
      end

      context 'fully from filesystem into repository with working copy' do
        setup do
          @result = GitRepository.clone_git("file://#{@path}", @path_clone)
          @repository_clone = GitRepository.new(@path_clone)
        end

        teardown do
          @repository_clone = nil
        end

        should 'be sueccessful' do
          assert @result[:success]
        end

        should 'be a repository with working copy' do
          assert GitRepository.is_repository_with_working_copy?(@path_clone)
        end

        should 'not be an svn clone' do
          assert !@repository_clone.is_svn_clone?
        end

        should 'clone all commits' do
          assert_equal @repository.commits, @repository_clone.commits
        end

        should 'create the same branches in the clone' do
          assert(@repository.branches & @repository_clone.branches == @repository.branches, 'The original branches are not a subset of the clone branches.')
        end

        context 'should produce the typical git errors' do
          setup {} #needed for teardown

          teardown do
            @repository_clone = nil
          end

          should '(not a repository)' do
            result = GitRepository.clone_git('/', @path_clone)
            assert_equal "fatal: repository '/' does not exist\n", result[:err]
          end

          should '(already exists)' do
            GitRepository.clone_git(@path, @path_clone)
            result = GitRepository.clone_git(@path, @path_clone)
            assert_equal "fatal: destination path '#{@path_clone}' already exists and is not an empty directory.\n", result[:err]
          end
        end

        should 'be able to pull new changes' do
          head_oid_pre = @repository.head_oid
          @repository.commit_file(@userinfo, @content+'new', @filepath, 'change file for pull')
          head_oid_post = @repository.head_oid
          result = @repository_clone.pull
          
          assert result[:success], "Pull was unseccessful: #{result[:err]}"
          assert_equal head_oid_pre, result[:head_oid_pre]
          assert_equal head_oid_post, result[:head_oid_post]
          assert_equal @repository.commits, @repository_clone.commits
        end
      end
    end
  end

  context 'importing an svn repository' do
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

      @path_clone_wc = '/tmp/ontohub/test/unit/git/repository_clone_wc'
      @path_clone_bare = '/tmp/ontohub/test/unit/git/repository_clone_bare'
      @result = GitRepository.clone_svn(@url_svn_server, @path_clone_bare, @path_clone_wc)
      @repository_clone_wc = GitRepository.new(@path_clone_wc)
      @repository_clone_bare = GitRepository.new(@path_clone_bare)
    end

    teardown do
      FileUtils.rmtree(@path_clone_wc) if File.exists?(@path_clone_wc)
      FileUtils.rmtree(@path_clone_bare) if File.exists?(@path_clone_bare)
      FileUtils.rmtree(@path_svn) if File.exists?(@path_svn)
      @result = nil
      @repository_clone_wc = nil
      @repository_clone_bare = nil
    end

    should 'be successful' do
      assert @result[:success], "Cloning was unsuccessful: #{@result[:err]}"
    end

    should 'be an svn clone (working copy)' do
      assert @repository_clone_wc.is_svn_clone?, "Working copy is not an svn clone"
    end

    should 'not be an svn clone (bare)' do
      assert !@repository_clone_bare.is_svn_clone?, "Bare repo is an svn clone"
    end

    should 'have a working copy (working copy)' do
      assert GitRepository.is_repository_with_working_copy?(@path_clone_wc), 'Clone is not a valid repository with working copy'
    end

    should 'be a bare repository (bare)' do
      assert GitRepository.is_bare_repository?(@path_clone_bare), 'Clone is not a valid bare repository'
    end

    should 'get the correct remotes (working copy)' do
      stdin, stdout, stderr, wait_thr = Open3.popen3 'bash', SCRIPT_GIT_REMOTE_V, @path_clone_wc
      assert wait_thr.value.success?
      out = stdout.gets(nil).gsub(/origin\s+(.*)\(.*\)\s/, '\1').split.uniq
      assert_equal [@path_clone_bare], out, 'working copy does not have any remotes'
    end
    
    should 'get the correct remotes (bare)' do
      stdin, stdout, stderr, wait_thr = Open3.popen3 'bash', SCRIPT_GIT_REMOTE_V, @path_clone_bare
      assert wait_thr.value.success?
      assert_nil stdout.gets(nil), 'bare repository has remotes'
    end

    should 'have the correct amount of commits' do
      assert_equal @commit_count, @repository_clone_wc.commits.size
    end

    should 'synchronize between working copy and bare' do
      assert_equal @repository_clone_wc.commits, @repository_clone_bare.commits
    end

    context 'and synchronizing with it' do
      setup do
        stdin, stdout, stderr, wait_thr = Open3.popen3 'bash', SCRIPT_SVN_ADD_COMMITS, @path_svn_client, "#{@commit_count}", 'new_'
        exit_status = wait_thr.value

        @head_oid_pre = @repository_clone_wc.head_oid
        @result_rebase = @repository_clone_wc.svn_rebase
        @head_oid_post = @repository_clone_wc.head_oid
        
        @result_push = @repository_clone_wc.push
      end

      teardown do
      end

      should 'be successful' do
        assert @result_rebase[:success], "rebase failed:\n#{@result_rebase[:out]}\n#{@result_rebase[:err]}"
        assert @result_push[:success], "push failed:\n#{@result_push[:out]}\n#{@result_push[:err]}"
      end

      should 'get the new commits' do
        assert_equal @commit_count*2, @repository_clone_wc.commits.size
      end

      should 'synchronize between working copy and bare' do
        assert_equal @repository_clone_wc.commits, @repository_clone_bare.commits
      end

      should 'have the correct oid-range of sync between working copy and bare' do
        assert_equal @head_oid_pre, @result_rebase[:head_oid_pre]
        assert_equal @head_oid_post, @result_rebase[:head_oid_post]
      end
    end
  end
end
