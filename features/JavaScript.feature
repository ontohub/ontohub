Feature: JavaScript

@rack-test
Scenario: Warning if JavaScript is deactivated
  Given I visit the landing page with deactivated javascript
  Then I should see a javascript-deactivated-warning

@javascript
Scenario: No warning if JavaScript is activated
  Given I visit the landing page with activated javascript
  Then I should see no javascript-deactivated-warning