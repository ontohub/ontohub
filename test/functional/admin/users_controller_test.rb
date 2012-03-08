require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase

  should route(:get, "/admin/users").to(:controller=> 'admin/users', :action => :index)
  should route(:get, "/admin/users/id").to(:controller=> 'admin/users', :action => :show, :id => 'id')
  should route(:get, "/admin/users/id/edit").to(:controller=> 'admin/users', :action => :edit, :id => 'id')
  should route(:put, "/admin/users/id").to(:controller=> 'admin/users', :action => :update, :id => 'id')
  should route(:delete, "/admin/users/id").to(:controller=> 'admin/users', :action => :destroy, :id => 'id')

  context 'on GET to index' do
    context 'not signed in' do
      setup do
        get :index
      end
      
      should set_the_flash.to(/admin privileges/)
      should respond_with :redirect
    end
    
    context 'signed in as normal user' do
      setup do
        sign_in Factory :user
        get :index
      end
      
      should set_the_flash.to(/admin privileges/)
      should respond_with :redirect
    end

    context 'signed in as admin user' do
      setup do
        sign_in Factory :admin
        get :index
      end
      
      should respond_with :success
    end
  end
  
end
