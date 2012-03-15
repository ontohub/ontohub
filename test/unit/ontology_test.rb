require 'test_helper'

class OntologyTest < ActiveSupport::TestCase
  should belong_to :logic
  should have_many :versions
  should have_many :comments
  
  should have_db_index(:uri).unique(true)
  should have_db_index(:state)
  should have_db_index(:logic_id)
  
  should_strip_attributes :name, :uri
  should_not_strip_attributes :description

  
  [ 'http://example.com/', 'https://example.com/' ].each do |val|
    should allow_value(val).for :name
  end

  [ nil, '','fooo', 'file://path/to/file' ].each do |val|
    should_not allow_value(val).for :name
  end
  

  context 'ontology instance' do
    setup do
      @ontology = Factory :ontology
    end
    
    should 'have to_s' do
      assert_equal @ontology.uri, @ontology.to_s
    end
  end
  
  context 'creating ontology with version' do
    setup do
      OntologyVersion.any_instance.expects(:parse_async).once
      
      @user                = Factory :user
      @remote_raw_file_url = 'http://colore.googlecode.com/svn/trunk/ontologies/arithmetic/robinson_arithmetic.clif'
      @ontology            = Ontology.new \
        :uri => 'fooo',
        :versions_attributes => [{
          remote_raw_file_url: @remote_raw_file_url
        }]
        
      @ontology.versions.first.user = @user
      @ontology.save!
    end
    
    should 'create a version with remote_raw_file_url' do
      assert_equal @remote_raw_file_url, @ontology.versions.first.remote_raw_file_url
    end
    
    context 'creating a permission' do
      setup do
        assert_not_nil @permission = @ontology.permissions.first
      end
      
      should 'with subject' do
        assert_equal @user, @permission.subject
      end
      
      should 'with role owner' do
        assert_equal 'owner', @permission.role
      end
    end
    
  end
end
