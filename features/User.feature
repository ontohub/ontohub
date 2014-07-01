Feature: User Feature
  This feature is for the integration tests of the user model,
  including registration and login.

Scenario: User Registration
  I want to create an Account at Ontohub.
  Given I visit the landing page.
  When I fill in the registration form.
  And click on the singup button.
  Then I should be on the after signup page
  And a new User with the given values is registered.
  But he is not confirmed.

Scenario: User Login
  I'm a registered user of Ontohub
  and want to log in.
  Given I am a registered and confirmed user.
  And I visit the landing page.
  When I fill in the login form.
  And click on the sign in button.
  Then I should be logged in.
