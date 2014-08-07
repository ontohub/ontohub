Feature: Status for Processing Ontologies
  As part of the status description system for admins
  there should be the possibility to gather information
  about processing ontologies.

@javascript
Scenario: Watching the list of processing ontologies
    Given i am logged in as an admin
    And i navigate to the status page
    When i click on the processing ontologies tab selector
    Then i should be redirected to the corresponding tab
