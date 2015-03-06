require 'spec_helper'

describe OntologyTypesController do

  let(:ontology_type)   { create :ontology_type }
  let!(:ontology)   { create :ontology, ontology_type: ontology_type }

  context "show" do
    context 'requesting standard representation' do
      before { get :show, id: ontology_type.to_param }

      it { should respond_with :success }
      it { should render_template :show }
    end

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
