require 'test_helper'

class EntitiesControllerTest < ActionController::TestCase
  
  should route(:get, "/ontologies/id/entities").to(:controller=> :entities, :action => :index, :ontology_id => 'id')
  
  context 'Ontology Instance' do
    setup do
      @ontology = FactoryGirl.create :ontology
    end
    
    context 'on GET to index' do
      setup do
        get :index, :ontology_id => @ontology.to_param
      end
      
      should respond_with :success
    end
    
  end
  
end
