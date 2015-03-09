require 'spec_helper'

describe Api::V1::MappingsController do
  let(:ontology) { create :linked_distributed_ontology }
  let(:mapping) { ontology.mappings.last }
  let(:repository) { ontology.repository }

  context 'on GET to index' do
    context 'requesting json representation', api_specification: true do
      let(:mappings_schema) do
        schema_for('ontology/commands/mappings')
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
        VCR.use_cassette 'api/json-schemata/ontology/mappings' do
          expect(response.body).
            to match_json_schema(mappings_schema)
        end
      end
    end
  end

  context 'on GET to show' do
    context 'requesting json representation', api_specification: true do
      let(:mapping_schema) { schema_for('mapping') }

      before do
        get :show,
          repository_id: ontology.repository.to_param,
          ontology_id: ontology.to_param,
          id: mapping.to_param,
          locid: mapping.locid,
          format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/mapping' do
          expect(response.body).to match_json_schema(mapping_schema)
        end
      end
    end
  end
end
