require 'test_helper'

class CartTest < ActiveSupport::TestCase
  context 'Associations' do
    should have_many :cart_items
  end
  
  context 'create' do
    setup do
      @cart = Cart.create
    end
    
    should 'be not Nil' do
      assert_not_nil @cart
    end
    should 'be empty' do
      assert @cart.empty?
    end
  end
  
  context 'adding Items' do
    setup do
      @cart = Cart.create
      @version = FactoryGirl.create :ontology_version
    end
    
    context 'Add ontoversion to cart' do
      setup do
        @cart.add @version
      end
      
      should 'add the ontoversion to the cart' do
        assert @version, @cart.find(@version.id)
      end
      should 'increase the number of items' do
        assert_equal 1, @cart.size
      end
    end
  end
end