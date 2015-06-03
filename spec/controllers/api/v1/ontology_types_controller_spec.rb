require 'spec_helper'

describe Api::V1::OntologyTypesController do
  context 'on GET to show' do
    let(:ontology_type)   { create :ontology_type }
    let!(:ontology)   { create :ontology, ontology_type: ontology_type }

    context 'requesting json representation', api_specification: true do
      let(:ontology_type_schema) { schema_for('ontology_type') }

      before do
        get :show,
          id: ontology_type.to_param,
          format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/ontology_type' do
          expect(response.body).to match_json_schema(ontology_type_schema)
        end
      end
    end
  end
end
