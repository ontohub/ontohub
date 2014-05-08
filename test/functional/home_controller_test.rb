require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  
  should route(:get, "/").to(:controller=> :home, :action => :index)

  context 'on GET to index' do
    context 'not signed in' do
      setup do
        get :index
      end
      should respond_with :success
      should render_template :index
      end
    
    context 'signed in' do
      setup do
        sign_in FactoryGirl.create :user
        get :index
      end
      should respond_with :success
      should render_template :index
    end
  end

end
