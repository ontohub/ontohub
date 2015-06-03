require 'spec_helper'

describe Api::V1::ProofAttemptConfigurationsController do
  let(:proof_attempt) { create :proof_attempt }
  let(:pa_configuration) { proof_attempt.proof_attempt_configuration }
  let(:theorem) { proof_attempt.theorem }
  let(:ontology) { theorem.ontology }
  let(:repository) { ontology.repository }

  context 'on GET to index' do
    context 'requesting json representation', api_specification: true do
      before do
        get :index,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param,
            locid: controllers_locid_for(ontology, :proof_attempt_configurations),
            format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end
    end
  end

  context 'on GET to selected_axioms' do
    context 'requesting json representation', api_specification: true do
      before do
        get :selected_axioms,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param,
            id: pa_configuration.to_param,
            locid: controllers_locid_for(pa_configuration, :selected_axioms),
            format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end
    end
  end

  context 'on GET to selected_theorems' do
    context 'requesting json representation', api_specification: true do
      before do
        get :selected_theorems,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param,
            id: pa_configuration.to_param,
            locid: controllers_locid_for(pa_configuration, :selected_theorems),
            format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end
    end
  end

  context 'on GET to show' do
    context 'requesting json representation', api_specification: true do
      let(:proof_attempt_configuration_schema) do
        schema_for('proof_attempt_configuration')
      end

      before do
        get :show,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param,
            id: pa_configuration.to_param,
            locid: pa_configuration.locid,
            format: :json
      end

      it { should respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/ontology/proof_attempt_configuration' do
          expect(response.body).
            to match_json_schema(proof_attempt_configuration_schema)
        end
      end
    end
  end
end
