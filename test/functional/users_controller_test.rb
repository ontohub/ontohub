require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  should route(:get, "/users/id").to(:controller=> :users, :action => :show, :id => 'id')

  context 'User Instance' do
    setup do
      @user = FactoryGirl.create :user
    end

    context 'without data' do
      context 'on GET to show' do
        setup do
          get :show, :id => @user.to_param
        end

        should respond_with :success
        should render_template :show
      end
    end

    context 'with data' do
      setup do
        FactoryGirl.create :comment, :user => @user
        FactoryGirl.create :ontology_version_with_file, :user => @user
      end
      context 'on GET to show' do
        setup do
          get :show, :id => @user.to_param
        end

        should respond_with :success
        should render_template :show
      end
    end
  end

end
