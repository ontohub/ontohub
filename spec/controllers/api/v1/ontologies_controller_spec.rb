require 'spec_helper'

describe Api::V1::OntologiesController do

  context 'Ontology Instance' do
    let(:ontology) { create :single_ontology, state: 'done' }
    let(:repository) { ontology.repository }

    context 'on GET to show' do
      context 'with format json', api_specification: true do
        let(:ontology_schema) { schema_for('ontology') }

        before do
          get :show,
            repository_id: repository.to_param,
            format:        :json,
            locid: ontology.locid,
            id: ontology.to_param
        end

        it { expect(subject).to respond_with :success }

        it 'respond with json content type' do
          expect(response.content_type.to_s).to eq('application/json')
        end

        it 'should return a representation that validates against the schema' do
          VCR.use_cassette 'api/json-schemata/ontology' do
            expect(response.body).to match_json_schema(ontology_schema)
          end
        end
      end
    end
  end
end
