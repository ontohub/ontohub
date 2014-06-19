Feature: Permission feature 
        This Feature should be hold the test for the Permissions
        like adding permissions or something like that
        
Background: 
  Given It exists an repository
  And a User with permission
  And a team
  
  @javascript
  Scenario: I want to give a team permissions to my
            repository
      Given I am logged in
      When i visit the permissions page of my repository
      And I fill in the name of an team
      And click on the suggested team
      Then the permission for the team should be added
      