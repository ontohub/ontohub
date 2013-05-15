require 'test_helper'

class LogicTest < ActiveSupport::TestCase
    context 'logic instance' do
    setup do
      @user = FactoryGirl.create :user
      @logic = FactoryGirl.create :logic, :user => @user
    end
    
    should 'have to_s' do
      assert_equal @logic.name, @logic.to_s
    end
  end
  
end
