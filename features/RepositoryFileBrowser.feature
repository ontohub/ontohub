Feature: RepositoryFileBrowser

Scenario: SingleOntology Display
  Given I have uploaded an ontology
  When I visit the file browser of the ontology's repository
  Then I should see the ontology's file
  And I should see the ontlogy next to the ontology's file
  And I should see no other ontologies next to the ontology's file

Scenario: DistributedOntology Display
  Given I have uploaded a distributed ontology
  When I visit the file browser of the ontology's repository
  Then I should see the ontology's file
  And I should see the ontlogy and its children next to the ontology's file
  And I should see no other ontologies next to the ontology's file

Scenario: DistributedOntology with Deleted Children Display
  Given I have uploaded a distributed ontology
  And Children of the ontology have been deleted
  When I visit the file browser of the ontology's repository
  Then I should see the ontology's file
  And I should see the ontlogy and its children next to the ontology's file
  And I should see no other ontologies next to the ontology's file
