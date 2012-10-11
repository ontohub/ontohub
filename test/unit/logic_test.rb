require 'test_helper'

class LogicTest < ActiveSupport::TestCase
    context 'logic instance' do
    setup do
      @logic = Factory :logic
    end
    
    should 'have to_s' do
      assert_equal @logic.name, @logic.to_s
    end
  end
  
end
