require 'test_helper'

class CartItemTest < ActiveSupport::TestCase
  context 'Associations' do
    should belong_to :cart
    should belong_to :ontology_version
  end
  
  
end