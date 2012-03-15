require 'test_helper'

class OntologiesControllerTest < ActionController::TestCase
  
  should_map_nested_resources :ontologies, :ontology_versions,
    :as     => 'versions',
    :except => [:new, :create, :show, :edit, :update, :destroy]
  
  context 'OntologyVersion Instance' do
    setup do
      OntologyVersion.any_instance.expects(:parse_async).once
      @version  = Factory :ontology_version_with_file
      @ontology = @version.ontology
    end
    
    context 'on GET to index' do
      setup do
        get :index, :ontology_id => @ontology.to_param
      end
      
      should respond_with :success
    end
  end
  
end
