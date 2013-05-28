require 'test_helper'

class OntologyVersionsControllerTest < ActionController::TestCase
  def fixture_file(name)
    Rails.root + 'test/fixtures/ontologies/xml/' + name
  end
  
  should_map_nested_resources :ontologies, :ontology_versions,
    :as     => 'versions',
    :except => [:show, :edit, :update, :destroy]
  
  context 'OntologyVersion of a DistributedOntology' do
    setup do
      OntologyVersion.any_instance.expects(:parse_async).once
      @user = FactoryGirl.create :user
      @ontology = FactoryGirl.create :distributed_ontology
      @ontology.import_xml_from_file fixture_file('test2.xml'), @user
      @version  = FactoryGirl.create :ontology_version, ontology: @ontology
      @ontology.reload
      @ontology_child = @ontology.children.first
    end

    context 'on GET to index of a child' do
      setup do
        get :index, ontology_id: @ontology_child.id
      end

      should 'assign the parents versions' do
        assert_equal [@version], assigns(:versions)
      end
    end
  end
    
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

      context 'for a single ontology' do
        should 'assign the right versions' do
          assert assigns(:versions)
        end
      end
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
        
        should respond_with :redirect
        should set_the_flash.to(/Your request is send to OOPS!/i)
      end

      context 'send second request' do
        context 'while pending, processing or done'
          setup do
            @myrequest = FactoryGirl.create :oops_request, state: :pending
            post :oops, :ontology_id => @ontology.to_param, ontology_version: @version, :id => @version.number
          end
        
          should respond_with :redirect
          should set_the_flash.to(/Already send to OOPS/i)
        end
        
        context 'when failed' do
          setup do
            post :oops, :ontology_id => @ontology.to_param, :id => @version.number
            @myresponse = FactoryGirl.create :oops_request, ontology_version: @version, state: :failed
          end
          
          should respond_with :redirect
          should set_the_flash.to(/Your request is send to OOPS!/i)
        end

    end
  end
  
end
