require 'test_helper'

# Tests a git repository
#
# Author: Eugen Kuksa <eugenk@informatik.uni-bremen.de>

class GitRepositoryTest < ActiveSupport::TestCase

  context 'creating and deleting a repository' do
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
      @path = '/tmp/ontohub/unit_test/git/repository'
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
        @filepath = 'path/file.txt'
        @content = 'Some content'
        @message = 'Some commit message'
        @repository.commit_file(@userinfo, @content, @filepath, @message)
        assert @repository.path_exists?(nil, @filepath)
        assert_equal @repository.get_current_file(nil, @filepath)[:name], @filepath.split('/')[-1]
        assert_equal @repository.get_current_file(nil, @filepath)[:content], @content
        assert_equal @repository.get_current_file(nil, 'path/file.txt')[:mime_type], Mime::Type.lookup('text/plain')
        assert_equal @repository.get_commit_message, @message
        assert_equal @repository.get_commit_author[:name], @userinfo[:name]
        assert_equal @repository.get_commit_author[:email], @userinfo[:email]
        # removed because of time zone issues
        #assert_equal Time.at(@repository.get_commit_author[:time]), Time.gm(@userinfo[:time])
      end

      should 'delete a file' do
        @repository.commit_file(@userinfo, @content, @filepath, @message)
        @repository.delete_file(@userinfo, @filepath)
        assert !@repository.path_exists?(nil, @filepath)
      end

      should 'overwrite a file' do
        content2 = "#{@content}_2"
        message2 = "#{@message}_2"
        @repository.commit_file(@userinfo, @content, @filepath, @message)
        first_commit_oid = @repository.head_oid
        @repository.commit_file(@userinfo, content2, @filepath, message2)
        assert_equal @repository.get_current_file(nil, @filepath)[:content], content2
        assert_equal @repository.get_commit_message(@repository.head_oid), message2
        assert_not_equal first_commit_oid, @repository.head_oid
      end
    end
  end

end
