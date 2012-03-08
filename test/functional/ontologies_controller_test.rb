require 'test_helper'

class OntologiesControllerTest < ActionController::TestCase
  
  should route(:get, "/ontologies").to(:controller=> :ontologies, :action => :index)
  should route(:get, "/ontologies/id").to(:controller=> :ontologies, :action => :show, :id => 'id')
  
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
  end
  
end
