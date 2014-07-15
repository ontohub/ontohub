require 'test_helper'

class OopsRequest::ResponsesTest < ActiveSupport::TestCase

  context 'creating a oops request' do
    setup do
      Oops::Client.stubs(:execute_request).returns \
        File.read("#{Rails.root}/test/fixtures/oops/sunrealm.xml")

      @version = FactoryGirl.create :ontology_version
      @entity  = FactoryGirl.create :entity,
        ontology: @version.ontology,
        name:     'Must be present',
        text:     '',
        iri:      'http://sweet.jpl.nasa.gov/1.1/sunrealm.owl#SunRealm'
      @request = @version.create_request
      @request.send :execute_and_save

      # delete this line if you want tests running after this to fail
      # (mocha 0.13.3)
      Oops::Client.unstub(:execute_request)
    end

    should 'have created a request with responses' do
      assert @request.responses.any?
    end

    should 'affected entity with should be connected with response' do
      assert @entity.oops_responses.any?
    end

  end

end
