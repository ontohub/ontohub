Given(/^I visit the landing page\.$/) do
  visit root_path
end

When(/^I fill in the registration form\.$/) do
  within "#new_user" do
    fill_in 'user_email',    :with => 'foobar@example.com'
    fill_in 'user_name',     :with => 'Foo Bar'
    fill_in 'user_password', :with => 'simple-password'
  end
end

When(/^click on the singup button\.$/) do
  within "#new_user" do
    click_on 'Sign Up'
  end
end

Then(/^I should be on the after signup page$/) do
  page.should have_content("Need Help?")
  page.should have_content("Welcome Foo Bar")
  current_path.should eq("/after_signup")
end

Then(/^a new User with the given values is registered\.$/) do
  @user = User.find_by_email("foobar@example.com")
  @user.should_not be_nil
end

Then(/^he is not confirmed\.$/) do
  @user.confirmed_at.should be_nil
  @user.confirmation_token.should_not be_nil
end

Given(/^I am a registered and confirmed user\.$/) do
  @password = SecureRandom.hex(10)

  @user = FactoryGirl.create :user, :password => @password
  @user.confirmed_at = Time.now
  @user.save!
end

When(/^I fill in the login form\.$/) do
  within '#sign_in' do
    fill_in 'user_email',    :with => @user.email
    fill_in 'user_password', :with => @password
  end
end

When(/^click on the sign in button\.$/) do
  within '#sign_in' do
    click_on 'Sign In'
  end
end

Then(/^I should be logged in\.$/) do
  page.should have_content(@user.name)
  page.should have_content("Signed in successfully")
end

Given(/^that I am really logged in$/) do
  steps %Q{
  Given I am a registered and confirmed user.
  And I visit the landing page.
  When I fill in the login form.
  And click on the sign in button.
  Then I should be logged in.
  }
end

Given(/^I visit the Account page$/) do
  visit root_path
  click_on 'Account'
end

Given(/^there is no existing API\-Key$/) do
  expect { find('form#new_api_key input#api_key_key') }.
    to raise_error(Capybara::ElementNotFound)
end

When(/^i click on the generate button$/) do
  find('form#new_api_key input[name=commit]').click
end

Then(/^i should see an API\-Key$/) do
  expect(find('form#new_api_key input#api_key_key').value).
    to eq(@user.api_keys.valid.first.key)
end

Given(/^I have an API-Key$/) do
  @api_key = ApiKey.create_new_key!(@user)
end

Then(/^i should see the existing API\-Key$/) do
  expect(find('form#new_api_key input#api_key_key').value).
    to eq(@api_key.key)
end

Then(/^i should see the new API\-Key$/) do
  key = find('form#new_api_key input#api_key_key').value
  expect(key).to eq(@user.api_keys.valid.first.key)
  expect(key).to_not eq(@api_key.key)
end
