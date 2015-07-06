require 'spec_helper'

describe Api::V1::LogicsController do
  let(:user) { create :user }
  let(:logic) { create :logic, user: user }

  context 'on GET to show' do
    context 'requesting xml representation', api_specification: true do
      before do
        # @request.env['HTTP_ACCEPT'] = 'text/xml'
        get :show, id: logic.to_param, format: :xml
      end

      it { expect(subject).to respond_with :success }

      it 'should respond as a application/rdf+xml' do
        expect(response.content_type).to eq('application/rdf+xml')
      end
    end
    context 'requesting json representation', api_specification: true do
      let(:logic_schema) { schema_for('logic') }

      before do
        get :show, id: logic.to_param, format: :json
      end

      it { expect(subject).to respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/logic' do
          expect(response.body).to match_json_schema(logic_schema)
        end
      end
    end
  end
end
