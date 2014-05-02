require 'integration_test_helper'

class SessionTest < ActionController::IntegrationTest

  test 'registration' do
    visit '/'
    within "#new_user" do
      fill_in 'user_email',    :with => 'foobar@example.com'
      fill_in 'user_name',     :with => 'Foo Bar'
      fill_in 'user_password', :with => 'simple-password'
      click_on 'Sign Up'
    end
    
    assert_equal "/", current_path
    assert_match /You have signed up successfully/, find(".alert-info").text
  end
  
  test 'login' do
    password = SecureRandom.hex(10)
    
    user = FactoryGirl.create :user, :password => password
    user.confirmed_at = Time.now
    user.save!
    
    visit '/'
    within '#sign_in' do
      fill_in 'user_email',    :with => user.email
      fill_in 'user_password', :with => password
      click_on 'Sign In'
    end
    
    assert_equal "/", current_path
    assert_match /#{user.name}/, find("nav .dropdown.user-dropdown a").text
  end
  
end
