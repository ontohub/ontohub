require 'spec_helper'

describe Api::V1::ChildrenController do
  let(:ontology) { create :linked_distributed_ontology }
  let(:repository) { ontology.repository }

  context 'on GET to index' do
    context 'requesting json representation', api_specification: true do
      let(:children_schema) do
        schema_for_command('ontology/children', :get, 200)
      end

      before do
        get :index,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param,
          locid: ontology.locid,
          format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/ontology/children' do
          expect(response.body).
            to match_json_schema(children_schema)
        end
      end
    end
  end
end
