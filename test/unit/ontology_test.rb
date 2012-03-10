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
end
