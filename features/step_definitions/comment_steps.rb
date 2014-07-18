Given(/^There is an ontology with version$/) do
  @ontology = FactoryGirl.create(:ontology_version).ontology
  @ontology.state = 'done'
  @ontology.save
end

Given(/^a User which is logged in$/) do
  @user = FactoryGirl.create :user
  login_as @user, :scope => :user
end

Given(/^he has permissions on the repository of the ontology$/) do
  @repository = @ontology.repository
  FactoryGirl.create :permission, subject: @user, item: @ontology.repository
end

Given(/^I am on the comment page of an ontology$/) do
  visit repository_ontology_comments_path(@repository, @ontology)
end

When(/^I am fill in text in the comment field$/) do
  @comment = 'very loooooooong comment'
  within '#new_comment' do
    fill_in 'Text', with: @comment
  end
end

When(/^I click on submit$/) do
  within '#new_comment' do
    click_button 'Create Comment'
  end
end

Then(/^there is a new comment$/) do
  page.should have_content @comment
end

Given(/^there is a comment$/) do
  @comment = FactoryGirl.create :comment, commentable: @ontology
end

When(/^I click on delete$/) do
  click_link "delete"
end

Then(/^the comment is deleted$/) do
  pending("javascript is needed")
  page.should_not have_content @comment.text
end
