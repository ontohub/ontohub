require 'spec_helper'

describe Api::V1::TheoremsController do
  let(:theorem) { create :theorem }
  let(:ontology) { theorem.ontology }
  let(:repository) { ontology.repository }

  context 'on GET to show' do
    context 'requesting json representation', api_specification: true do
      let(:theorem_schema) do
        schema_for('theorem')
      end

      before do
        get :show,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param,
          id: theorem.to_param,
          locid: theorem.locid,
          format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/ontology/theorem' do
          expect(response.body).
            to match_json_schema(theorem_schema)
        end
      end
    end
  end
end
