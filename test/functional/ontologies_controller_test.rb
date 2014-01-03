require 'test_helper'

class OntologiesControllerTest < ActionController::TestCase
  
  should_map_nested_resources :repositories, :ontologies, :except => [:new, :create, :destroy]
  
  context 'Ontology Instance' do
    setup do
      @ontology   = FactoryGirl.create :single_ontology, state: 'done'
      @repository = @ontology.repository
      @user       = FactoryGirl.create :user
      
      2.times { FactoryGirl.create :entity, :ontology => @ontology }
    end
    
    context 'on GET to index' do
      context 'for a repository' do
        setup do
          get :index, repository_id: @repository.path
        end

        should respond_with :success
        should render_template :index_repository
      end
      context 'for the whole website' do
        setup do
          get :index
        end
        should respond_with :success
        should render_template :index_global
      end
    end
    
    context 'on GET to show' do
      setup do
        Entity.delete_all
      end
      
      context 'with format json' do
        setup do
          get :show,
            repository_id: @repository.path,
            format:        :json,
            id:            @ontology.to_param
        end
        
        should respond_with :success

        should 'respond with json content type' do
          assert_equal "application/json", response.content_type.to_s
        end

      end
      
      context 'without entities' do
        setup do
          get :show,
            repository_id: @repository.path,
            id:            @ontology.to_param
        end
        
        should respond_with :redirect
        should redirect_to("entities"){  repository_ontology_entities_path(@repository, @ontology, :kind => 'Symbol') }
      end
      
      context 'with entity of kind Class' do
        setup do
          entity = FactoryGirl.create :entity, :ontology => @ontology, :kind => 'Class'
          get :show,
            repository_id: @repository.path,
            id:            @ontology.to_param
        end
        
        should respond_with :redirect
        should redirect_to("entities"){  repository_ontology_entities_path(@repository, @ontology, :kind => 'Class' ) }
      end
    end
    
    context 'owned by signed in user' do
      setup do
        sign_in @user
        @repository.permissions.create! \
          :role    => 'owner',
          :subject => @user
      end
      
      context 'on GET to edit' do
        setup do
          get :edit,
            repository_id: @repository.path,
            id:            @ontology.to_param
        end
        
        should respond_with :success
        should render_template :edit
      end
      
      context 'on PUT to update' do
        setup do
          put :update, 
            repository_id: @repository.path,
            id:            @ontology.to_param,
            name:          'foo bar'
        end
        
        should redirect_to("show action"){ [@repository, @ontology] }
      end
    end
  end
  
end
