require 'spec_helper'

describe Api::V1::ProverOutputsController do
  let(:proof_attempt) { create :proof_attempt }
  let(:prover_output) { proof_attempt.prover_output }
  let(:theorem) { proof_attempt.theorem }
  let(:ontology) { theorem.ontology }
  let(:repository) { ontology.repository }

  context 'on GET to show' do
    context 'requesting json representation', api_specification: true do
      let(:prover_output_schema) do
        schema_for('prover_output')
      end

      before do
        get :show,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param,
            theorem_id: theorem.to_param,
            proof_attempt_id: proof_attempt.to_param,
            locid: prover_output.locid,
            format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/ontology/prover_output' do
          expect(response.body).
            to match_json_schema(prover_output_schema)
        end
      end
    end
  end
end
