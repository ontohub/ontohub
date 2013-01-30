require 'test_helper'

# Tests a triple store
#
# Author: Daniel Couto Vale <danielvale@uni-bremen.de>
#
class TripleStoreTest < ActiveSupport::TestCase

  context 'Empty Triple List' do
    setup do
      @store = TripleStore.new([])
    end

    should "expect no domains" do 
      assert_equal [], @store.domains('b','c')
    end

    should "expect no relations" do
      assert_equal [],  @store.relations('a','c')
    end

    should "expect no ranges" do
      assert_equal [], @store.ranges('a','b')
    end
  end

end
