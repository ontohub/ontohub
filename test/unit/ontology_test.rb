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

  context 'Validations' do
    ['http://example.com/', 'https://example.com/', 'file://path/to/file'].each do |val|
      should allow_value(val).for :uri
    end
  end

  [nil, '', 'fooo'].each do |val|
    should_not allow_value(val).for :uri
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
      
      @user       = Factory :user
      @source_uri = 'http://colore.googlecode.com/svn/trunk/ontologies/arithmetic/robinson_arithmetic.clif'
      @ontology   = Ontology.new \
        :uri => 'http://example.com/ontology',
        :versions_attributes => [{
          source_uri: @source_uri
        }]
        
      @ontology.versions.first.user = @user
      @ontology.save!
    end
    
    should 'create a version with source_uri' do
      assert_equal @source_uri, @ontology.versions.first.source_uri
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
