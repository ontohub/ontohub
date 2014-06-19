Feature: Comment feature


Background:
  Given There is an ontology with version
  And a User which is logged in
  And the has permissions on the repository of the ontology
  
Scenario: I want to create an comment to a given ontology
  Given I am on the comment page of an ontology
  When I am fill in text in comment field
  And I click on submit
  Then there is a new comment
  
Scenario: I want to delete a comment
  Given there is a comment
  And I am on the comment page of an ontology
  When I click on delete
  Then the comment is deleted