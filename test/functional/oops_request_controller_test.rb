require 'test_helper'

class OopsRequestsControllerTest < ActionController::TestCase
  context 'OntologyVersion OOPS-Integration' do
    
    should route(:get, "/ontologies/12/versions/45/oops_request").to(:controller => :oops_requests, :action => :show, :ontology_id => '12', :ontology_version_id => '45' )
    should route(:post, "/ontologies/12/versions/45/oops_request").to(:controller => :oops_requests, :action => :create, :ontology_id => '12', :ontology_version_id => '45')

    setup do
      OntologyVersion.any_instance.expects(:parse_async).once
      @version  = FactoryGirl.create :ontology_version_with_file
      @ontology = @version.ontology
    end
    
    context 'on GET to oops' do
      setup do
        @request.env['HTTP_REFERER'] = 'http://test.com/'
        OopsRequest.any_instance.stubs(:run)
      end
      
      context 'test with OOPS!' do
        setup do
          post :create, :ontology_id => @ontology.to_param, :ontology_version_id => @version.number, :format => :json
        end
        
        should respond_with :created
        #should set_the_flash.to(/Your request is send to OOPS!/i)
      end

      context 'send second request' do
        context 'while pending, processing or done' do
          setup do
            FactoryGirl.create :oops_request, state: :pending, ontology_version: @version
            post :create, :ontology_id => @ontology.to_param, :ontology_version_id => @version.number, :format => :json
          end
        
          should respond_with :forbidden
          #should set_the_flash.to(/Already send to OOPS/i)
        end
        
        context 'when failed' do
          setup do
           FactoryGirl.create :oops_request, ontology_version: @version, state: :failed
           post :create, :ontology_id => @ontology.to_param, :ontology_version_id => @version.number, :format => :json
          end
          
          should respond_with :created
        end
      end
     
      context 'on GET to SHOW' do
        context 'with OopsRequest' do
          setup do
            FactoryGirl.create :oops_request, ontology_version: @version, state: :pending
            get :show, :ontology_id => @ontology.to_param, :ontology_version_id => @version.number, :format => :json
          end
          
          should respond_with :success
        end
        
        context 'without OopsRequest' do
          should "raise not found" do
            assert_raises ActiveRecord::RecordNotFound do 
              get :show, :ontology_id => @ontology.to_param, :ontology_version_id => @version.number, :format => :json
            end
          end
          
        end
        
      end
    end
  end
end