Feature: Permission feature
        This Feature should be hold the test for the Permissions
        like adding permissions or something like that

Background:
  Given there exists a repository
  And a User with a permission
  And a team

  @javascript
  Scenario: I want to give a team permissions to my
            repository
      Given I am logged in
      When I visit the permissions page of my repository
      And I fill in the name of an team
      And click on the suggested team
      Then the permission for the team should be added
