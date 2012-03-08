require 'test_helper'

class AxiomsControllerTest < ActionController::TestCase
  
  should route(:get, "/ontologies/id/axioms").to(:controller=> :axioms, :action => :index, :ontology_id => 'id')
  
  context 'Ontology Instance' do
    setup do
      @ontology = Factory :ontology
    end
    
    context 'on GET to index' do
      setup do
        get :index, :ontology_id => @ontology.to_param
      end
      
      should respond_with :success
    end
    
  end
  
end
