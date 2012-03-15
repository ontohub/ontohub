require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  should route(:get, "/search").to(:controller=> :search, :action => :index)
  
end
