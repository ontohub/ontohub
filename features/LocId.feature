Feature: Resolving LocId IRIs

@require_accept_html
Scenario: Loading a SingleOntology
  Given there is a single ontology
  When I visit the ontology via the loc/id
  Then I should get a response with a status of 200
  And I should have an API-command matching 'symbols'

@require_accept_html
Scenario: Loading a DistributedOntology
  Given there is a distributed ontology
  When I visit the ontology via the loc/id
  Then I should get a response with a status of 200
  And I should have an API-command matching 'children'

@require_accept_html
Scenario: Loading a Single-in-Distributed Ontology
  Given there is a single-in-distributed ontology
  When I visit the ontology via the loc/id
  Then I should get a response with a status of 200
  And I should have an API-command matching 'symbols'
