require 'integration_test_helper'

class SessionTest < ActionController::IntegrationTest

  test 'registration' do
    visit '/'
    click_link 'Register'
    assert_equal new_user_registration_path, current_path
    
    within "#new_user" do
      fill_in 'E-Mail',   :with => 'foobar@example.com'
      fill_in 'Name',     :with => 'Foo Bar'
      fill_in 'user_password', :with => 'simple-password'
      fill_in 'Password confirmation', :with => 'simple-password'
      click_on 'Create Account'
    end
    
    assert_equal "/", current_path
    assert_match /You have registered successfully/, find(".alert-info").text
  end
  
  test 'login' do
    password = SecureRandom.hex(10)
    
    user = FactoryGirl.create :user, :password => password
    user.confirmed_at = Time.now
    user.save!
    
    visit '/'
    click_link 'Log in'
    assert_equal new_user_session_path, current_path
    
    within '#new_user' do
      fill_in 'E-Mail',   :with => user.email
      fill_in 'Password', :with => password
      click_on 'Log in'
    end
    
    assert_equal "/", current_path
    assert_match /Logged in successfully/, find(".alert-info").text
  end
  
end
