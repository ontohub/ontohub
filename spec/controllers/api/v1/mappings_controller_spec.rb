require 'spec_helper'

describe Api::V1::MappingsController do
  context 'on GET to show' do
    let(:ontology) { create :linked_distributed_ontology }
    let(:mapping) { ontology.mappings.last }

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
