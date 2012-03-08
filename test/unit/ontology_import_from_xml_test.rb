require 'test_helper'

class OntologyImportFromXMLTest < ActiveSupport::TestCase
  def fixture_file(name)
    File.open(Rails.root + 'test/fixtures/ontologies/' + name)
  end

  context 'Import valid Ontology' do
    setup do
      @ontology = Factory :ontology
      @ontology.import_from_xml fixture_file('valid.xml')
    end

    should 'save logic' do
      assert_equal 'OWL', @ontology.logic.name
    end

    context 'entity count' do
      should 'be 5' do
        assert_equal 5, @ontology.entities.count
      end
    end

    context 'axiom count' do
      should 'be 1' do
        assert_equal 1, @ontology.axioms.count
      end
    end
  end
end
