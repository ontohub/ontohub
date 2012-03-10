require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  should_strip_attributes :name, :email
  should_not_strip_attributes :password
  
  context 'User instance' do
    setup do
      @mails_sent = ActionMailer::Base.deliveries.size
      @user = Factory :user
    end
    
    should 'sent email' do
      assert_equal @mails_sent+1, ActionMailer::Base.deliveries.size
    end
    
    should 'have email' do
      assert_not_nil @user.email
    end
    
    should 'have name' do
      assert_not_nil @user.name
    end
    
    should 'not have deleted_at' do
      assert_nil @user.deleted_at
    end
    
    context 'after deletion' do
      setup do
        @user.delete
      end
      
      should 'have blank email' do
        assert_nil @user.email
      end
      
      #should 'have blank password' do
      #  assert_nil @user.password
      #end
      
      should 'have deleted_at' do
        assert_not_nil @user.deleted_at
      end
    end
    
  end
  
end
