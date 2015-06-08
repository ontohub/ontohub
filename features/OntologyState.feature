Feature: OntologyState feature

@javascript
Scenario: I have uploaded an ontology I am on
          the detail page of the ontology while
          it is parsed
  Given there is an ontology with a "pending" version
  And I visit the detail page of the ontology
  When we change the state of the ontology to: failed
  Then the page should change the state on its own

@javascript
Scenario: I have uploaded a, now failed, ontology
  and I want to view the ontology page
  Given there is an ontology with a "failed" version
  And i am logged in as an admin
  When I visit the sub-page "ontology_versions" of the ontology
  Then I should see the "failed" state inside of "div#state_infos"
