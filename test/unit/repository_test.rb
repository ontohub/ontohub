require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase

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
          @version = @repository.save_file(@file_path, @target_path, @message, @user)
        end

        should 'create the file in the git repository' do
          assert @repository.git.path_exists?(@target_path)
        end

        should 'create the file with correct contents in the git repository' do
          assert_equal @content, @repository.git.get_file(@target_path).content
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
          assert_difference 'Worker.jobs.count' do
            @repository.save_file(@file_path, @target_path, @message, @user)
          end

          file = File.open(@file_path, 'w')
          file.puts("#{@content}\n#{@content}")
          file.close

          @repository.save_file(@file_path, @target_path, @message, @user)
        end

        teardown do
          @repository.destroy
        end

        should 'create a new ontology version' do
          ontology = @repository.ontologies.where(basepath: File.basepath(@target_path)).first!
          assert_equal 2, ontology.versions.count
        end
      end
    end

  end

end
