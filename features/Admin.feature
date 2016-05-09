Feature: Admin Feature
  As a admin, I have different possibilities than a normal user.

  Background:
    Given I am logged in as a admin

  Scenario: Edit User
    Given there is a user
    When I visit the users overview page
    And I visit the users edit page
    And I change the name of the user
    And I submit the form
    Then I should see the users overview page and the updated user