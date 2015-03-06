require 'spec_helper'

describe MappingsController do
  let(:ontology) { create :linked_distributed_ontology }
  let(:mapping) { ontology.mappings.last }

  context 'on GET to show' do
    context 'requesting standard representation' do
      before do
        get :show,
          repository_id: ontology.repository.to_param,
          ontology_id: ontology.to_param,
          id: mapping.to_param
      end

      it { should respond_with :success }
      it { should render_template :show }
    end

    context 'requesting json representation', api_specification: true do
      let(:mapping_schema) { schema_for('mapping') }

      before do
        get :show,
          repository_id: ontology.repository.to_param,
          ontology_id: ontology.to_param,
          id: mapping.to_param,
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
