require 'test_helper'

class OntologyTest < ActiveSupport::TestCase
  should belong_to :logic
  should have_many :versions
  
  should_strip_attributes :name, :uri
  should_not_strip_attributes :description

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
      @source_uri = 'http://example.com/dummy.ontology'
      @ontology   = Ontology.new \
        :uri => 'fooo',
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
