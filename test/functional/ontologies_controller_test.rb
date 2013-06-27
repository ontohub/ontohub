require 'test_helper'

class OntologiesControllerTest < ActionController::TestCase
  
  should_map_nested_resources :repositories, :ontologies
  should route(:get, "/repositories/path/ontologies/bulk").to(:controller=> :ontologies, :action => :bulk, repository_id: 'path')
  
  context 'Ontology Instance' do
    setup do
      @ontology   = FactoryGirl.create :single_ontology, state: 'done'
      @repository = @ontology.repository
      @user       = FactoryGirl.create :user
      
      2.times { FactoryGirl.create :entity, :ontology => @ontology }
    end
    
    context 'on GET to index' do
      context 'without search' do
        setup do
          get :index, repository_id: @repository.path
        end
        
        should respond_with :success
        should render_template :index
        should render_template 'ontologies/_ontology'
      end
      
      context 'with search' do
        setup do
          @search = @ontology.name
          get :index,
            repository_id: @repository.path,
            search:        @search
        end
        
        should respond_with :success
        should render_template :index
        should render_template 'ontologies/_ontology'
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
        should respond_with_content_type :json
      end
      
      context 'without entities' do
        setup do
          get :show,
            repository_id: @repository.path,
            id:            @ontology.to_param
        end
        
        should respond_with :redirect
        should redirect_to("entities"){  ontology_entities_path(@ontology, :kind => 'Symbol') }
      end
      
      context 'with entity of kind Class' do
        setup do
          entity = FactoryGirl.create :entity, :ontology => @ontology, :kind => 'Class'
          get :show,
            repository_id: @repository.path,
            id:            @ontology.to_param
        end
        
        should respond_with :redirect
        should redirect_to("entities"){  ontology_entities_path(@ontology, :kind => 'Class' ) }
      end
    end
    
    context 'signed in as editor' do
      setup do
        sign_in @user
        @repository.permissions.create! \
          :role    => 'editor',
          :subject => @user
      end
      
      context 'on GET to bulk' do
        setup do
          get :bulk, repository_id: @repository.path
        end
        
        should respond_with :success
        should render_template :bulk
      end
      
      context 'on GET to new' do
        setup do
          get :new, repository_id: @repository.path
        end
        
        should respond_with :success
        should render_template :new
      end
      
      context 'on POST to create' do
        
        context 'with invalid input' do
          context 'without format' do
            setup do
              post :create,
                repository_id: @repository.path,
                ontology: {
                  iri: 'fooo',
                  versions_attributes: [{
                    source_url: ''
                  }],
                }
            end
            
            should respond_with :success
            should render_template :new
          end
          
          context 'with format :json' do
            setup do
              post :create,
                format: :json,
                repository_id: @repository.path,
                ontology: {
                  iri: 'fooo',
                  versions_attributes: [{
                    source_url: ''
                  }],
                }
            end
            
            should respond_with :unprocessable_entity
          end
        end
        
        context 'with valid input' do
          context 'without format' do
            setup do
              OntologyVersion.any_instance.expects(:parse_async).once
              
              post :create, repository_id: @repository.path, :ontology => {
                iri: 'http://example.com/dummy.ontology',
                versions_attributes: [{
                  source_url: 'http://example.com/dummy.ontology'
                }],
              }
            end

            should respond_with :redirect
          end
          
          context 'with format :json' do
            setup do
              OntologyVersion.any_instance.expects(:parse_async).once
              
              post :create,
                format: :json,
                repository_id: @repository.path,
                ontology: {
                  iri: 'http://example.com/dummy.ontology',
                  versions_attributes: [{
                    source_url: 'http://example.com/dummy.ontology'
                  }],
                }
            end

            should respond_with :created
          end
        end
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
