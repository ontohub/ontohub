Feature: Resolving LocId IRIs

Scenario: Loading a SingleOntology
  Given there is a single ontology
  When I visit the ontology via the loc/id
  Then i should get a response with a status of 200
  And i should have an API-command matching 'symbols'

Scenario: Loading a DistributedOntology
  Given there is a distributed ontology
  When I visit the ontology via the loc/id
  Then i should get a response with a status of 200
  And i should have an API-command matching 'children'

Scenario: Loading a Single-in-Distributed Ontology
  Given there is a single-in-distributed ontology
  When I visit the ontology via the loc/id
  Then i should get a response with a status of 200
  And i should have an API-command matching 'symbols'
