require 'spec_helper'

describe Api::V1::SentencesController do
  context 'on GET to show' do
    let(:sentence) { create :sentence }
    let(:ontology) { sentence.ontology }

    context 'requesting json representation', api_specification: true do
      let(:sentence_schema) { schema_for('sentence') }

      before do
        get :show,
          repository_id: ontology.repository.to_param,
          ontology_id: ontology.to_param,
          id: sentence.to_param,
          locid: sentence.locid,
          format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/sentence' do
          expect(response.body).to match_json_schema(sentence_schema)
        end
      end
    end
  end
end
