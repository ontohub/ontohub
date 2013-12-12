require 'test_helper'

class DistributedOntologyTest < ActiveSupport::TestCase
  
  should have_many :children
  
  context 'distributed ontology instance' do
    setup do
      @ontology = FactoryGirl.create :distributed_ontology, iri: 'http://example.com/foo'
    end
    
    should 'generate sub iri' do
      assert_equal 'http://example.com/foo?bar', @ontology.iri_for_child('bar')
    end
    
    should 'generate sub iri that already is an iri' do
      assert_equal 'http://example.com/dummy', @ontology.iri_for_child('http://example.com/dummy')
    end
    
  end
  
end
