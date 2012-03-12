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
        
        should set_the_flash.to(/not authorized/)
        should redirect_to("root path"){ :root }
      end
      
    end
    
  end
  
end
