require 'test_helper'

class HetsTest < ActiveSupport::TestCase

  context 'Hets deployment' do
    should 'have an existing hets binary and lib' do
      assert_nothing_raised do
        Hets::Config.new
      end
    end
  end

end
