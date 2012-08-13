require 'test_helper'

class OntologyImportXMLTest < ActiveSupport::TestCase
  def fixture_file(name)
    Rails.root + 'test/fixtures/ontologies/xml/' + name
  end

  context 'Import single Ontology' do
    setup do
      @ontology = Factory :single_ontology
      @ontology.import_xml_from_file fixture_file('test1.xml')
    end

    should 'save logic' do
      assert_equal 'CASL', @ontology.logic.try(:name)
    end

    context 'entity count' do
      should 'be correct' do
        count = @ontology.entities.count
        assert_equal 2, count
        assert_equal count, @ontology.entities_count
      end
    end

    context 'sentence count' do
      should 'be correct' do
        count = @ontology.sentences.count
        assert_equal 1, count
        assert_equal count, @ontology.sentences_count
      end
    end
  end
  
  context 'Import distributed Ontology' do
    setup do
      @ontology = Factory :distributed_ontology
      @ontology.import_xml_from_file fixture_file('test2.xml')
    end
    
    should 'create single ontologies' do
      assert_equal 4, SingleOntology.count
    end
    
    should 'have children ontologies' do
      assert_equal 4, @ontology.children.count
    end
    
    should 'have no logic' do
      assert_nil @ontology.logic.try(:name)
    end
    
    should 'have no entities' do
      assert_nil @ontology.entities_count
    end
    
    should 'have no sentences' do
      assert_nil @ontology.sentences_count
    end
    
    context 'first child ontology' do
      setup do
        @child = @ontology.children.first
      end
      
      should 'have entities' do
        assert_equal 2, @child.entities_count
      end
      
      should 'have sentences' do
        assert_equal 1, @child.sentences_count
      end
    end
  end
end
