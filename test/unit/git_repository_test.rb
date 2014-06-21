require 'test_helper'

# Tests a git repository
#
# Author: Eugen Kuksa <eugenk@informatik.uni-bremen.de>

class GitRepositoryTest < ActiveSupport::TestCase

  ENV['LANG'] = 'C'

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

      should 'only list the newest commits if a limit (and offset) is specified' do
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
          @commit_add2,
          @commit_other3,
          @commit_other2], @repository.commits(limit: 3, offset: 2) { |commit_oid| commit_oid })
        assert_equal([
          @commit_other1,
          @commit_change1,
          @commit_add1], @repository.commits(limit: 3, offset: 6) { |commit_oid| commit_oid })
        assert_equal([
          @commit_other1,
          @commit_change1,
          @commit_add1], @repository.commits(limit: 4, offset: 6) { |commit_oid| commit_oid })
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
        assert_equal([
          @commit_add1
        ], @repository.commits(path: @filepath, limit: 7, offset: 5) { |commit_oid| commit_oid })
      end

      should 'find out if a file is at the current state' do
        assert !@repository.has_changed?(@filepath, @commit_add1,    @commit_add1)
        assert @repository.has_changed?(@filepath,  @commit_add1,    @commit_change1)
        assert @repository.has_changed?(@filepath,  @commit_add1,    @commit_delete1)
        assert @repository.has_changed?(@filepath,  @commit_delete1, @commit_add2)
        assert @repository.has_changed?(@filepath,  @commit_delete1, @commit_delete2)
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
        assert_equal @repository.changed_files(@commit1).first.name, 'file.xml'
      end

      should 'have the right path in the list when using the first commit' do
        assert_equal @repository.changed_files(@commit1).first.path, @filepath
      end

      should 'have the right type in the list when using the first commit' do
        assert_equal @repository.changed_files(@commit1).first.type, :add
      end

      should 'have the right mime type in the list when using the first commit' do
        assert_equal @repository.changed_files(@commit1).first.mime_type, Mime::Type.lookup_by_extension(@file_extension)
      end

      should 'have the right mime category in the list when using the first commit' do
        assert_equal @repository.changed_files(@commit1).first.mime_category, 'application'
      end

      should 'have the right editable in the list when using the first commit' do
        assert_equal @repository.changed_files(@commit1).first.editable?, true
      end



      should 'have the right file count when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).size, 1
      end

      should 'have the right name in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first.name, @filepath.split('/')[-1]
      end

      should 'have the right path in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first.path, @filepath
      end

      should 'have the right type in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first.type, :change
      end

      should 'have the right mime type in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first.mime_type, Mime::Type.lookup_by_extension(@file_extension)
      end

      should 'have the right mime category in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first.mime_category, 'application'
      end

      should 'have the right editable in the list when using a commit in the middle' do
        assert_equal @repository.changed_files(@commit2).first.editable?, true
      end



      should 'have the right file count when using the HEAD' do
        assert_equal @repository.changed_files.size, 1
      end

      should 'have the right name in the list when using the HEAD' do
        assert_equal @repository.changed_files.first.name, @filepath.split('/')[-1]
      end

      should 'have the right path in the list when using the HEAD' do
        assert_equal @repository.changed_files.first.path, @filepath
      end

      should 'have the right type in the list when using the HEAD' do
        assert_equal @repository.changed_files.first.type, :delete
      end

      should 'have the right mime type in the list when using the HEAD' do
        assert_equal @repository.changed_files.first.mime_type, Mime::Type.lookup_by_extension(@file_extension)
      end

      should 'have the right mime category in the list when using the HEAD' do
        assert_equal @repository.changed_files.first.mime_category, 'application'
      end

      should 'have the right editable in the list when using the HEAD' do
        assert_equal @repository.changed_files.first.editable?, true
      end
    end
  end

end
