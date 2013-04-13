require 'test_helper'

class OntologyVersionsControllerTest < ActionController::TestCase
  
  should_map_nested_resources :ontologies, :ontology_versions,
    :as     => 'versions',
    :except => [:show, :edit, :update, :destroy]
  
  context 'OntologyVersion Instance' do
    setup do
      OntologyVersion.any_instance.expects(:parse_async).once
      @version  = FactoryGirl.create :ontology_version_with_file
      @ontology = @version.ontology
    end
    
    context 'on GET to index' do
      setup do
        get :index, :ontology_id => @ontology.to_param
      end
      
      should respond_with :success
    end
    
    context 'on GET to oops' do
      setup do
        @request.env['HTTP_REFERER'] = 'http://test.com/'
        OopsRequest.any_instance.stubs(:run)
      end
      context 'test with OOPS!' do
        setup do
          post :oops, :ontology_id => @ontology.to_param, :id => @version.number
        end
        
        should set_the_flash.to(/send to OOPS/i)
      end

      context 'send second request' do
        setup do
          post :oops, :ontology_id => @ontology.to_param, :id => @version.number
          post :oops, :ontology_id => @ontology.to_param, :id => @version.number
        end
        
        should set_the_flash.to(/send to OOPS/i)
      end

    end
  end
  
end
