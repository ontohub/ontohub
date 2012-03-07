require 'test_helper'

class OntologyImportFromXMLTest < ActiveSupport::TestCase
  def fixture_path(name)
    Rails.root + 'test/fixtures/ontologies/' + name
  end

  setup do
    ontology = Ontology.from_xml_file(fixture_path('valid.xml'))
  end

  should 'save logic' do
    assert_equal 'OWL', ontology.logic.name
  end
end
