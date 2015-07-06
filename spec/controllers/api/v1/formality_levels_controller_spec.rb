require 'spec_helper'

describe Api::V1::FormalityLevelsController do
  context 'on GET to show' do
    let(:formality_level) { create :formality_level }

    context 'requesting json representation', api_specification: true do
      let(:formality_level_schema) { schema_for('formality_level') }

      before do
        get :show,
          id: formality_level.to_param,
          format: :json
      end

      it { expect(subject).to respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/formality_level' do
          expect(response.body).to match_json_schema(formality_level_schema)
        end
      end
    end
  end
end
