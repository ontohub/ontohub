Feature: Destroying and recreating a Repository

Scenario: Destroying and recreating a Repository
  When I create a Repository with name "test"
  And I upload an ontology with a Theorem
  And I attempt to prove the Theorem
  And I destroy the repository
  And I create a Repository with name "test"
  And I upload the same ontology again
  And I attempt to prove the Theorem
  And I visit the proof attempt's loc/id
  Then I should get a response with a status of 200
  And a headline should include "Proof Attempt of [the theorem's name]"
