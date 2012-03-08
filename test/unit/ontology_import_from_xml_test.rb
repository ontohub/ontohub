require 'test_helper'

class OntologyImportFromXMLTest < ActiveSupport::TestCase
  def fixture_file(name)
    File.open(Rails.root + 'test/fixtures/ontologies/' + name)
  end

  context 'foo' do
    setup do
      ontology = Ontology.import_from_xml(fixture_file('valid.xml'))
    end

    should 'save logic' do
      assert_equal 'OWL', ontology.logic.name
    end
  end
end
