require 'test_helper'

class KeysControllerTest < ActionController::TestCase
  
  should route(:get, "keys").to(:controller=> :keys, :action => :index)

  context 'not signed in' do
    setup do
      get :index
    end

    should respond_with :redirect
  end

  context 'signed in' do
    setup do
      @user = FactoryGirl.create :user
      sign_in @user
    end

    context 'GET to new' do
      setup do
        get :new
      end

      should respond_with :success
      should render_template :new
    end

    context 'POST to create' do
      setup do
        post :create, key: FactoryGirl.attributes_for(:key)
      end

      should set_the_flash.to(/successfully created/)
      should redirect_to("index"){ :keys }
    end

    context 'existing key' do
      setup do
        @key = FactoryGirl.create :key, user: @user
      end

      context 'GET to index' do
        setup do
          get :index
        end

        should respond_with :success
        should render_template :index
        should render_template 'keys/_key'
      end

      context 'DELETE to destroy' do
        setup do
          delete :destroy, id: @key.id
        end

        should redirect_to("index"){ :keys }
      end
    end
  end

end
