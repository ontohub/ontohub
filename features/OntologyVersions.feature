Feature: OntologyVersions

Scenario: When displaying the versions of a Single in Distributed
          Ontology i should actually see its versions.
  Given there is a distributed ontology
  When i visit the versions tab of a child ontology
  Then i should see the corresponding versions

