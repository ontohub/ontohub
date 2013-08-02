require 'test_helper'

class EntitiesControllerTest < ActionController::TestCase
  
  should route(:get, "/ontologies/id/entities").to(:controller=> :entities, :action => :index, :ontology_id => 'id')
  
  context 'Ontology Instance' do
    setup do
      @user = FactoryGirl.create :user
      @logic = FactoryGirl.create :logic, :user => @user
      @ontology = FactoryGirl.create :single_ontology, :logic => @logic
    end
    
    context 'on GET to index' do
      setup do
        get :index, :ontology_id => @ontology.to_param
      end
      
      should respond_with :success
      should_not render_template(partial: '_oops_state')
    end

  end

  context 'OWL Ontology instance' do
    setup do
      @user = FactoryGirl.create :user
      @logic = FactoryGirl.create :logic, :name => 'OWL2', :user => @user
      @ontology = FactoryGirl.create :single_ontology, :logic => @logic
    end

    context 'on GET to index' do
      setup do
        get :index, :ontology_id => @ontology.id
      end

      should respond_with :success
      should render_template(partial: '_oops_state')
    end
  end
  
end
