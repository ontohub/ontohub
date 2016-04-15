require 'spec_helper'

describe Api::V1::ProofStatusesController do
  let(:proof_status) { create :proof_status_open }

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
      let(:proof_status_schema) { schema_for('proof_status') }

      before do
        get :show,
          id: proof_status.to_param,
          format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/proof_status' do
          expect(response.body).
            to match_json_schema(proof_status_schema)
        end
      end
    end
  end
end
