require 'spec_helper'

describe Api::V1::LogicMappingsController do
  let(:logic_mapping) { create :logic_mapping }

  context 'on GET to index' do
    context 'requesting json representation', api_specification: true do
      before do
        get :index, format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end
    end
  end

  context 'on GET to show' do
    context 'requesting json representation', api_specification: true do
      let(:logic_mapping_schema) { schema_for('logic_mapping') }

      before do
        get :show,
          id: logic_mapping.to_param,
          locid: logic_mapping.locid,
          format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/logic_mapping' do
          expect(response.body).
            to match_json_schema(logic_mapping_schema)
        end
      end
    end
  end
end
