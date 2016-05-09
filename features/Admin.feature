Feature: Admin Feature
  As a admin, I have different possibilities than a normal user.

  Background:
    Given I am logged in as a admin

  Scenario: Edit user name
    Given there is a user
    When I visit the users overview page
    And I visit the users edit page
    And I change the name of the user
    And I submit the form
    Then I should see the users overview page and the updated user name

  Scenario: Edit user email adress
    Given there is a user
    When I visit the users overview page
    And I visit the users edit page
    And I change the email adress of the user
    And I submit the form
    Then I should see the users overview page and the updated user email adress

  Scenario: Edit user to admin
    Given there is a user
    When I visit the users overview page
    And I visit the users edit page
    And I allow the user admin status
    And I submit the form
    Then I should see the users overview page and the updated admin user status

  Scenario: Edit user to non admin
    Given there is a user
    When I visit the users overview page
    And I visit the users edit page
    And I delete the user admin status
    And I submit the form
    Then I should see the users overview page and the updated non admin user status