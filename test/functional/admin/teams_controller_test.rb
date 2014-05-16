require 'test_helper'

class Admin::TeamsControllerTest < ActionController::TestCase

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
        sign_in FactoryGirl.create :user
        get :index
      end

      should set_the_flash.to(/admin privileges/)
      should respond_with :redirect
    end

    context 'signed in as admin user' do
      setup do
        sign_in FactoryGirl.create :admin
        get :index
      end

      should respond_with :success
    end
  end

end
