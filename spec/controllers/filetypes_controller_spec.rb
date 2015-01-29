require 'spec_helper'

describe FiletypesController do

  context 'should return valid json on correct request' do
    let(:iri) { 'http://ontohub.org/non-existence/foobar.clif' }
    let(:mime_type) { 'text/clif' }
    let(:file_extension) { '.clif' }

    before do
      allow_any_instance_of(Hets::FiletypeCaller).to receive(:call).
        and_return("#{iri}: #{mime_type}")
      post :create, iri: iri
    end

    it { should respond_with :success }
    it 'should contain the iri' do
      expect(response.body).to include(%{"iri":"#{iri}"})
    end
    it 'should contain the mime_type' do
      expect(response.body).to include(%{"mime_type":"#{mime_type}"})
    end
    it 'should contain the file_extension' do
      expect(response.body).to include(%{"extension":"#{file_extension}"})
    end
  end

  context 'should return valid json on erroneous request' do
    let(:iri) { 'http://ontohub.org/non-existence/foobar.clif' }
    let(:mime_type) { 'text/clif' }
    let(:file_extension) { '.clif' }

    before do
      allow_any_instance_of(Hets::FiletypeCaller).to receive(:call).
        and_raise(Hets::HetsError)
      post :create, iri: iri
    end

    it { should respond_with 415 }
    it 'should contain the status' do
      expect(response.body).to include(%{"status":415})
    end
    it 'should contain the message' do
      expect(response.body).
        to include('"message":"Media Type not supported"')
    end
  end
end
