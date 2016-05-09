Given(/^I am logged in as a admin$/) do
  @admin = FactoryGirl.create :admin
  login_as @admin, :scope => :user
end

Given(/^there is a user$/) do
  @user = FactoryGirl.create :user
  @user_name = @user.name
end

When(/^I visit the users overview page$/) do
  visit admin_users_path
end

When(/^I visit the users edit page$/) do
  within(:css, '#list_users') do
    @edit_button = first(:css, 'tbody > tr').find_link('edit')
    @edit_button.click
  end
end

When(/^I change the name of the user$/) do
  fill_in 'Name', with: "NewUser"
end

When(/^I submit the form$/) do
  click_button('Update User')
end

Then(/^I should see the users overview page and the updated user$/) do
  within(:css, '#list_users') do
    expect(page).to have_content("NewUser")
    expect(page).not_to have_content("@user_name")
  end
end
