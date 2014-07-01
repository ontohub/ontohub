Feature: OntologyState feature

Scenario: I have uploaded an ontology I am on
          the detail page of the ontology while
          it is parsed
  Given There is an ontology
  And I visit the detail page of the ontology
  When now the state will be updated
  Then the page should change the state on its own
