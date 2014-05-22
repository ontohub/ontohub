Feature: User Feature
  This feature is for the integration tests of the user model,
  including registration and login.

Scenario: User Registration
  I want to create an Account at Ontohub.
  Given i visit the landing page.
  When fill out the registration form.
  And click on the singup button.
  Then i should be on the after signup page
  And a new User with given values is registred.
  But it is not confirmed.
  
Scenario: User Login
  I'm a registered user of Ontohub
  and want to login.
  Given I am an registered and confirmed user.
  And i visit the landing page.
  When i fill out the login form.
  And click on the signin button.
  Then i should be logged in.