require 'test_helper'

class OntologiesControllerTest < ActionController::TestCase
  
  should_map_resources :ontologies
  
  context 'Ontology Instance' do
    setup do
      @ontology = Factory :ontology
    end
    
    context 'on GET to index' do
      setup do
        get :index
      end
      
      should respond_with :success
    end
    
    context 'on GET to show' do
      setup do
        get :show, :id => @ontology.to_param
      end
      
      should respond_with :success
    end
    
    context 'on GET to edit' do
      setup do
        get :edit, :id => @ontology.to_param
      end
      
      should respond_with :success
    end
    
    context 'on PUT to update' do
      setup do
        put :update, 
          :id   => @ontology.to_param,
          :name => 'foo bar'
      end
      
      should redirect_to("show action"){ @ontology }
    end
  end
  
end
