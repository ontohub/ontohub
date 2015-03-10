require 'spec_helper'

describe Api::V1::RepositoriesController do
  context 'on GET to show' do
    let(:repository){ create :repository }

    context 'requesting json representation', api_specification: true do
      let(:repository_schema) { schema_for('repository') }

      before do
        get :show,
          id: repository.to_param,
          format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/repository' do
          expect(response.body).to match_json_schema(repository_schema)
        end
      end
    end
  end
end
