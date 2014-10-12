require 'spec_helper'

describe 'OopsRequest::Responses' do
  context 'creating a oops request' do
    let!(:version) { FactoryGirl.create :ontology_version }
    let!(:entity) do
      FactoryGirl.create :entity,
        ontology: version.ontology,
        name:     'Must be present',
        text:     '',
        iri:      'http://sweet.jpl.nasa.gov/1.1/sunrealm.owl#SunRealm'
    end
    let!(:request) { version.create_request }

    before do
      allow(Oops::Client).to(receive(:execute_request) do
        File.read("#{Rails.root}/test/fixtures/oops/sunrealm.xml")
      end)
      request.send :execute_and_save
    end

    it 'have created a request with responses' do
      expect(request.responses).not_to be_empty
    end

    it 'affected entity with should be connected with response' do
      expect(entity.oops_responses).not_to be_empty
    end
  end
end
