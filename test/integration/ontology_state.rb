require 'integration_test_helper'

class OntologyStateTest < ActionController::IntegrationTest

  setup do
    @ontology = FactoryGirl.create :ontology
  end

  test 'ontology state' do
    visit ontology_path(@ontology)

    # check current status
    assert_equal "pending", find("#ontology-state span").text

    # process version
    @ontology.update_attribute :state, 'done'

    # wait for polling
    sleep 2

    # is the refresh-button inserted?
    assert_equal "refresh", find("#ontology-state .btn").text

    # has the state text changed?
    assert_equal "done",    find("#ontology-state span").text
  end

end
