require 'test_helper'

class TeamUsersControllerTest < ActionController::TestCase
  
  should_map_nested_resources :teams, :team_users, \
    :as     => 'users',
    :except => [:index, :new, :show, :edit, :delete]
  
  context 'teams' do
    setup do
      @admin = Factory :user # team admin
      @user  = Factory :user
      @team  = Factory :team,
        :admin_user => @admin
    end
    
    context 'adding a user' do
      context 'by admin' do
        setup do
          sign_in @admin
          xhr :post, :create,
            :team_id   => @team.id,
            :team_user => {:user_id => @user.id}
        end
        
        should render_template '/teams/_user'
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
        
        should render_template '/teams/_user'
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
      
      context 'other user deleting team admin' do
        setup do
          sign_in @user
        end
        should 'throw not found exception' do
          assert_raises ActiveRecord::RecordNotFound do
            xhr :delete, :destroy,
              :team_id   => @team.id,
              :id        => @admin.id
          end
        end
      end
    end
  end
  
end
