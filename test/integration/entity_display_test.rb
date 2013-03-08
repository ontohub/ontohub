require 'integration_test_helper'

class SessionTest < ActionController::IntegrationTest
=begin
  test 'text does not contain name' do
    entity = FactoryGirl.create :entity_without_iri
   
    visit ontology_entities_path(entity.ontology)
    ths = all('th')
    save_and_open_page
    assert_equal 2, ths.size
  end
=end

end
