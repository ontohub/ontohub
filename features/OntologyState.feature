Feature: OntologyState feature

@javascript
Scenario: I have uploaded an ontology I am on
          the detail page of the ontology while
          it is parsed
  Given there is an ontology with a pending version
  And I visit the detail page of the ontology
  When we change the state of the ontology to: failed
  Then the page should change the state on its own
