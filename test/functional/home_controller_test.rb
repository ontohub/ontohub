require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  
  # should route(:get, "/").to(:controller=> :home, :action => :show)
  
  context 'on GET to show' do
    context 'not signed in' do
      setup do
        get :show
      end
      
      should respond_with :success
      should assign_to :versions
      should assign_to :comments
      should render_template :show
    end
    
    context 'signed in' do
      setup do
        sign_in Factory :user
        get :show
      end
      
      should respond_with :success
      should assign_to :versions
      should assign_to :comments
      should render_template :show
    end
  end
  
end
