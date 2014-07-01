Given(/^There is an ontology$/) do
  @ontology = FactoryGirl.create :ontology
  @user = FactoryGirl.create :admin
  login_as @user, scope: :user
end

Given(/^I visit the detail page of the ontology$/) do
  pending("Tim knows what is to do and said i should make this comment")
end

When(/^now the state will be updated$/) do
  pending
end

Then(/^the page should change the state on its own$/) do
  pending
end
