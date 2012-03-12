require 'test_helper'

class PermissionsControllerTest < ActionController::TestCase
  
  should_map_nested_resources :ontologies, :permissions,
    :except => [:new, :edit, :show]
  
  context 'permissions' do
    setup do
      @ontology = Factory :ontology
      @user     = Factory :user
    end
    
    context 'on GET to index' do
      
      context 'not signed in' do
        setup do
          get :index, :ontology_id => @ontology.to_param
        end
        
        should respond_with :redirect
        should set_the_flash.to(/log in/)
      end
      
      context 'signed in as user' do
        setup do
          sign_in @user
          get :index, :ontology_id => @ontology.to_param
        end
        
        should respond_with :success
        should render_template :index
      end
      
      
    end
    
  end
  
end
