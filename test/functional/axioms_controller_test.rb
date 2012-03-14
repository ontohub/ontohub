require 'test_helper'

class AxiomsControllerTest < ActionController::TestCase
  
  should route(:get, "/ontologies/id/axioms").to(:controller=> :axioms, :action => :index, :ontology_id => 'id')
  
  context 'Ontology Instance' do
    setup do
      @axiom    = Factory :axiom
      @ontology = @axiom.ontology
    end
    
    context 'on GET to index' do
      setup do
        get :index, :ontology_id => @ontology.to_param
      end
      
      should respond_with :success
      should render_template :index
      should render_template 'axioms/_axiom'
    end
    
  end
  
end
