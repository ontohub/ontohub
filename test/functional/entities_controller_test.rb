require 'test_helper'

class EntitiesControllerTest < ActionController::TestCase
  
  should route(:get, "/repositories/path/ontologies/id/entities").to(
    :controller => :entities,
    :action => :index,
    :repository_id => 'path',
    :ontology_id => 'id'
  )
  
  context 'Ontology Instance' do
    setup do
      @user = FactoryGirl.create :user
      @logic = FactoryGirl.create :logic, :user => @user
      @ontology = FactoryGirl.create :single_ontology, :logic => @logic
      @repository = @ontology.repository
    end
    
    context 'on GET to index' do
      setup do
        get :index, repository_id: @repository.to_param, ontology_id: @ontology.to_param
      end
      
      should respond_with :success
      should_not render_template(partial: '_oops_state')
    end

  end

  context 'OWL Ontology instance' do
    setup do
      @user = FactoryGirl.create :user
      @logic = FactoryGirl.create :logic, :name => 'OWL', :user => @user
      @ontology = FactoryGirl.create :single_ontology, :logic => @logic
      @repository = @ontology.repository
    end

    context 'on GET to index' do
      setup do
        get :index, repository_id: @repository.to_param, ontology_id: @ontology.to_param
      end

      should respond_with :success
      should render_template(partial: '_oops_state')
    end
  end
  
end
