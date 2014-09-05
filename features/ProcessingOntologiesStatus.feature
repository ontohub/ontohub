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

Scenario: Seeing the right information for processing ontologies
    Given i have 5 processing ontologies
    And i am logged in as an admin
    When i am on the processing ontologies tab
    Then i should see the processing ontologies
