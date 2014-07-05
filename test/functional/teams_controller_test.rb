require 'test_helper'

class TeamsControllerTest < ActionController::TestCase

  should_map_resources :teams

  context 'not signed in' do
    context 'on GET to index' do
      setup do
        get :index
      end

      should set_the_flash.to(/not authorized/)
      should redirect_to("root path"){ :root }
    end
  end

  context 'signed in' do
    setup do
      @user = FactoryGirl.create :user
      sign_in @user
    end

    context 'on GET to index without teams' do
      setup do
        get :index
      end

      should respond_with :success
      should render_template :index
    end

    context 'on GET to new' do
      setup do
        get :new
      end

      should respond_with :success
      should render_template :new
    end

    context 'with teams' do
      setup do
        @team = FactoryGirl.create :team,
          :admin_user => @user
      end

      context 'on GET to index' do
        setup do
          get :index
        end

        should respond_with :success
        should render_template :index
      end

      context 'on GET to show' do
        setup do
          get :show, :id => @team.to_param
        end

        should respond_with :success
        should render_template :show
      end

      context 'on GET to edit' do
        setup do
          get :edit, :id => @team.to_param
        end

        should respond_with :success
        should render_template :edit
      end

      context 'on DELETE to destroy' do
        context 'by team admin' do
          setup do
            delete :destroy, :id => @team.id
          end

          should redirect_to("index"){ :teams }
          should set_the_flash.to(/destroyed/)
        end

        context 'by non-admin' do
          setup do
            @member = FactoryGirl.create :user
            @team.users << @member
            sign_in @member
            delete :destroy, :id => @team.id
          end

          should redirect_to("root"){ :root }
          should set_the_flash.to(/not authorized/)
        end
      end
    end
  end

end
