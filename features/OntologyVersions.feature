Feature: OntologyVersions

Scenario: When displaying the versions of a Single in Distributed
          Ontology i should actually see its versions.
  Given there is a distributed ontology
  When i visit the versions tab of a child ontology
  Then i should see the corresponding versions

Scenario: Displaying view buttons on ontology versions without repository permission
  Given there is an ontology
  When I visit the versions tab of the ontology
  Then I should see a "View" button for each version
  And I shouldn't see a "Edit" button for each version

@javascript
Scenario: Displaying an edit button on the latest ontology if it is failed with repository permission
  Given I have an account
  And I am logged in
  And there is an ontology with a "failed" version
  And I have permissions to edit the ontology
  And there is a ontology file
  When I visit the versions tab of the ontology
  And I should see a "Edit" button for the latest version
  And I should see a "View" button for every other version
  And I click the edit button
  Then I should see edit page of the ontology

Scenario: Don't display an edit button if the failed version is not the latest one
  Given I have an account
  And I am logged in
  And there is an ontology with a "failed" version
  And there is a newer "done" version
  And I have permissions to edit the ontology
  When I visit the versions tab of the ontology
  Then I should see a "View" button for each version
  And I shouldn't see a "Edit" button for each version
