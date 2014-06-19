Feature: OntologyState feature

Scenario: I have uploaded an ontology an watching
          the detail page of the ontology while
          it is parsed
  Given There is an ontology
  And i visit the detail page of the ontology
  When now the state will be updatet
  Then the page should change the state on it own