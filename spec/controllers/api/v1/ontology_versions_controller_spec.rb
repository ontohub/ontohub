require 'spec_helper'

describe Api::V1::OntologyVersionsController do
  let(:version) { create :ontology_version_with_file }
  let(:ontology) { version.ontology }
  let(:repository) { ontology.repository }

  context 'on GET to index' do
    context 'requesting json representation', api_specification: true do
      let(:ontology_versions_schema) do
        schema_for('ontology/commands/ontology_versions')
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
        VCR.use_cassette 'api/json-schemata/ontology/ontology_versions' do
          expect(response.body).
            to match_json_schema(ontology_versions_schema)
        end
      end
    end
  end

  context 'on GET to show' do
    context 'requesting json representation', api_specification: true do
      let(:ontology_version_schema) { schema_for('ontology_version') }

      before do
        get :show,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param,
          reference: version.number,
          id: version.to_param,
          locid: version.locid,
          format: :json
      end

      it { expect(subject).to respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/ontology_version' do
          expect(response.body).
            to match_json_schema(ontology_version_schema)
        end
      end
    end
  end
end
