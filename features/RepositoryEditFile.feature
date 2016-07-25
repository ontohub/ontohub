Feature: RepositoryEditFile

Scenario: View the Ontologies of the file (SingleOntology)
  Given I have uploaded an ontology
  When I visit the file view of the ontology
  Then I should see all the file's ontologies

Scenario: View the Ontologies of the file (DistributedOntology)
  Given I have uploaded a distributed ontology
  When I visit the file view of the ontology
  Then I should see all the file's ontologies

Scenario: View the Ontologies of the file (DistributedOntology with deleted children)
  Given I have uploaded a distributed ontology
  And Children of the ontology have been deleted
  When I visit the file view of the ontology
  Then I should see all the file's ontologies
