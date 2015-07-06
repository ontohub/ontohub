require 'spec_helper'

describe Api::V1::SentencesController do
  let(:sentence) { create :sentence }
  let(:ontology) { sentence.ontology }
  let(:repository) { ontology.repository }

  context 'on GET to index' do
    context 'requesting json representation', api_specification: true do
      let(:sentences_schema) do
        schema_for('ontology/commands/sentences')
      end

      before do
        get :index,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param,
          locid: ontology.locid,
          format: :json
      end

      it { expect(subject).to respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/ontology/sentences' do
          expect(response.body).
            to match_json_schema(sentences_schema)
        end
      end
    end
  end

  context 'on GET to show' do
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

      it { expect(subject).to respond_with :success }

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
