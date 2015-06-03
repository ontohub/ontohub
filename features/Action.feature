Feature: Action Feature
  This feature represents asynchronous handling for long
  operations by creating intermediate action records.

  Scenario: Initial Waiting Status for Action
    Given that I have requested the creation of a combination
    And that I have a corresponding action
    When I request that action
    Then I should get a 200 response
    And the body should be valid for an action-response
    And it should contain a field "status" of "waiting"

  Scenario: Final redirect for Action
    Given that I have requested the creation of a combination
    And that I have a corresponding action
    And the combination is ready
    When I request that action
    Then I should get a 303 response
    And it should contain a field "status" of "See Other"
    And it should redirect to the combination-ontology
