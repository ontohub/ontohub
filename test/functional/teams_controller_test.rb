require 'test_helper'

class TeamsControllerTest < ActionController::TestCase
  
  should_map_resources :teams
  
  context 'not signed in' do
    context 'on GET to index' do
      setup do
        get :index
      end
      
      should redirect_to("log in"){ :new_user_session }
    end
  end
  
  context 'signed in' do
    setup do
      @user = Factory :user
      sign_in @user
    end
    
    context 'on GET to index without teams' do
      setup do
        get :index
      end
      
      should respond_with :success
      should assign_to(:team_users).with{ [] }
    end
    
    context 'on GET to new' do
      setup do
        get :new
      end
      
      should respond_with :success
    end
    
    context 'with teams' do 
      setup do
        @team = Factory :team,
          :admin_user => @user
      end
      
      context 'on GET to index' do
        setup do
          get :index
        end
        
        should assign_to(:team_users).with{ @team.team_users }
        should respond_with :success
      end
    end
  end
  
end
