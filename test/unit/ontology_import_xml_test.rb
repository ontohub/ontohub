require 'test_helper'

class OntologyImportXMLTest < ActiveSupport::TestCase
  def fixture_file(name)
    Rails.root + 'test/fixtures/ontologies/xml/' + name
  end

  context 'Import valid Ontology' do
    setup do
      @ontology = Factory :ontology
      @ontology.import_xml_from_file fixture_file('valid.xml')
    end

    should 'save logic' do
      assert_equal 'OWL', @ontology.logic.name
    end

    context 'entity count' do
      should 'be correct' do
        count = @ontology.entities.count
        assert_equal 5, count
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
end
