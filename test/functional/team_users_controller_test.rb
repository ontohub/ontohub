require 'test_helper'

class TeamUsersControllerTest < ActionController::TestCase

  should_map_nested_resources :teams, :team_users,
    :as     => 'users',
    :except => [:new, :show, :edit, :delete]

  context 'teams' do
    setup do
      @admin = FactoryGirl.create :user # team admin
      @user  = FactoryGirl.create :user
      @team  = FactoryGirl.create :team,
        :admin_user => @admin
    end

    context 'on GET to index' do
      context 'as admin' do
        setup do
          sign_in @admin
          get :index, :team_id => @team.to_param
        end

        should render_template 'relation_list/_relation_list'
        should render_template :index
        should respond_with :success
      end

      context 'as user' do
        setup do
          sign_in @user
          get :index, :team_id => @team.to_param
        end
        should set_the_flash.to(/not authorized/)
        should redirect_to("root path"){ :root }
      end
    end

    context 'adding a user' do
      context 'by admin' do
        setup do
          sign_in @admin
          xhr :post, :create,
            :team_id   => @team.id,
            :team_user => {:user_id => @user.id}
        end

        should render_template 'team_users/_team_user'
        should respond_with :success
      end
    end

    context 'with one user' do
      context 'removing the last user' do
        setup do
          sign_in @admin
            xhr :delete, :destroy,
              :team_id   => @team.id,
              :id        => @team.team_users.first.id
        end

        should 'return a helpful error message' do
          assert_match /What the hell/, response.body
        end

        should respond_with :unprocessable_entity
      end
    end

    context 'with two users' do
      setup do
        @team_user = @team.team_users.create! :user => @user
      end

      context 'setting the admin flag' do
        setup do
          sign_in @admin
          xhr :put, :update,
            :team_id   => @team.id,
            :id        => @team_user.id,
            :team_user => {:admin => 1}
        end

        should render_template 'team_users/_team_user'
        should respond_with :success
      end

      context 'team admin deleting other user' do
        setup do
          sign_in @admin
          xhr :delete, :destroy,
            :team_id   => @team.id,
            :id        => @team_user.id
        end

        should respond_with :success
      end

    end
  end

end
