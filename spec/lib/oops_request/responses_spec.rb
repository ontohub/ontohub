require 'spec_helper'

describe 'OopsRequest::Responses' do
  context 'creating a oops request' do
    let!(:version) { create :ontology_version }
    let!(:symbol) do
      create :symbol,
        ontology: version.ontology,
        name:     'Must be present',
        text:     '',
        iri:      'http://sweet.jpl.nasa.gov/1.1/sunrealm.owl#SunRealm'
    end
    let!(:request) { version.create_request }

    before do
      allow(Oops::Client).to(receive(:execute_request) do
        File.read(fixture_file("oops/sunrealm.xml"))
      end)
      request.send :execute_and_save
    end

    it 'have created a request with responses' do
      expect(request.responses).not_to be_empty
    end

    it 'affected symbol with should be connected with response' do
      expect(symbol.oops_responses).not_to be_empty
    end
  end
end
