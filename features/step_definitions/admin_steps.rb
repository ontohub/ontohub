Given(/^I am logged in as a admin$/) do
  @admin = FactoryGirl.create :admin
  login_as @admin, :scope => :user
end

Given(/^there is a user$/) do
  @user = FactoryGirl.create :user
  @user_name = @user.name
  @user_email = @user.email
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

Then(/^I should see the users overview page and the updated user name$/) do
  within(:css, '#list_users') do
    expect(page).to have_content("NewUser")
    expect(page).not_to have_content("@user_name")
  end
end

When(/^I change the email adress of the user$/) do
    fill_in 'E-Mail', with: "newuser@example.com"
end

Then(/^I should see the users overview page and the updated user email adress$/) do
  within(:css, '#list_users') do
    expect(page).to have_content("newuser@example.com")
    expect(page).not_to have_content("@user_email")
  end
end

When(/^I allow the user admin status$/) do
  check('Admin')
end

Then(/^I should see the users overview page and the updated admin user status$/) do
  expect(@user.reload.admin).to eq(true)
  within(:css, '#list_users') do
    expect(page).to have_content("#{@user.name}")
    expect(page).to have_content("#{@user.email}")
  end
end

When(/^I delete the user admin status$/) do
  uncheck('Admin')
end

Then(/^I should see the users overview page and the updated non admin user status$/) do
  expect(@user.reload.admin).to eq(false)
  within(:css, '#list_users') do
    expect(page).to have_content("#{@user.name}")
    expect(page).to have_content("#{@user.email}")
  end
end
