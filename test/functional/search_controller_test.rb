require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  
  should route(:get, "symbols").to(:controller=> :search, :action => :index)
  
end
