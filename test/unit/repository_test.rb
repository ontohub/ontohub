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
        @content = '(Cat x)'

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
          @commit_oid = @repository.save_file(@file_path, @target_path, @message, @user)
        end

        should 'create the file in the git repository' do
          assert @repository.git.path_exists?(@target_path)
        end

        should 'create the file with correct contents in the git repository' do
          assert_equal @repository.git.get_file(@target_path)[:content], @content
        end

        should 'create a new ontology with a default name' do
          assert_equal @repository.ontologies.count, 1
          assert_equal @repository.ontologies.first.name, 'Save_file'
        end

        should 'create a new ontology with only one version pointing to the commit' do
          o = @repository.ontologies.first
          assert_equal o.versions.count, 1
          assert_equal o.versions.first[:commit_oid], @commit_oid
        end

        should 'create a new ontology with only one version belonging to the right user' do
          v = @repository.ontologies.first.versions.first
          assert_equal v.user, @user
        end
      end

      context 'that exists' do
        setup do
          @repository.save_file(@file_path, @target_path, @message, @user)
          
          file = File.open(@file_path, 'w')
          file.puts("#{@content}\n#{@content}")
          file.close
          
          @repository.save_file(@file_path, @target_path, @message, @user)
        end

        should 'create a new ontology version' do
          flunk 'not implemented the test yet'
        end
      end
    end
  end
  
  context 'saving a file an ontology' do
    setup do
      OntologyVersion.any_instance.expects(:parse_async).once
      
      @user       = FactoryGirl.create :user
      @source_url = 'http://colore.googlecode.com/svn/trunk/ontologies/arithmetic/robinson_arithmetic.clif'
      @ontology   = Ontology.new \
        :iri => 'http://example.com/ontology',
        :versions_attributes => [{
          source_url: @source_url
        }]
        
      @ontology.versions.first.user = @user
      @ontology.repository = FactoryGirl.create(:repository)
      @ontology.save!
    end
    
    should 'create a version with source_url' do
      assert_equal @source_url, @ontology.versions.first.source_url
    end
    
  end
end
