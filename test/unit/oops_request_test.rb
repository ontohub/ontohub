require 'test_helper'

class OopsRequestTest < ActiveSupport::TestCase
  
  context 'creating a oops request' do
    setup do
      Oops::Client.stubs(:execute_request).returns \
        File.read("#{Rails.root}/test/fixtures/oops/sunrealm.xml")
      
      @version = FactoryGirl.create :ontology_version
      @request = @version.create_request
      
      # delete this line if you want tests running after this to fail
      # (mocha 0.13.3)
      Oops::Client.unstub(:execute_request)
    end
    
    should 'have created a request with responses' do
      assert @request.responses.any?
    end
    
  end

end
