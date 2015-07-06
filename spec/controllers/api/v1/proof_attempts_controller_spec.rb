require 'spec_helper'

describe Api::V1::ProofAttemptsController do
  let(:proof_attempt) { create :proof_attempt }
  let(:theorem) { proof_attempt.theorem }
  let(:ontology) { theorem.ontology }
  let(:repository) { ontology.repository }

  context 'on GET to index' do
    context 'requesting json representation', api_specification: true do
      before do
        get :index,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param,
            theorem_id: theorem.to_param,
            locid: controllers_locid_for(theorem, :proof_attempts),
            format: :json
      end

      it { expect(subject).to respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end
    end
  end

  context 'on GET to used_axioms' do
    context 'requesting json representation', api_specification: true do
      before do
        get :used_axioms,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param,
            theorem_id: theorem.to_param,
            id: proof_attempt.to_param,
            locid: controllers_locid_for(proof_attempt, :used_axioms),
            format: :json
      end

      it { expect(subject).to respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end
    end
  end

  context 'on GET to used_theorems' do
    context 'requesting json representation', api_specification: true do
      before do
        get :used_theorems,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param,
            theorem_id: theorem.to_param,
            id: proof_attempt.to_param,
            locid: controllers_locid_for(proof_attempt, :used_theorems),
            format: :json
      end

      it { expect(subject).to respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end
    end
  end

  context 'on GET to generated_axioms' do
    context 'requesting json representation', api_specification: true do
      before do
        get :generated_axioms,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param,
            theorem_id: theorem.to_param,
            id: proof_attempt.to_param,
            locid: controllers_locid_for(proof_attempt, :generated_axioms),
            format: :json
      end

      it { expect(subject).to respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end
    end
  end

  context 'on GET to show' do
    context 'requesting json representation', api_specification: true do
      let(:proof_attempt_schema) do
        schema_for('proof_attempt')
      end

      before do
        get :show,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param,
          theorem_id: theorem.to_param,
          id: proof_attempt.to_param,
          locid: proof_attempt.locid,
          format: :json
      end

      it { expect(subject).to respond_with :success }

      it 'respond with json content type' do
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'should return a representation that validates against the schema' do
        VCR.use_cassette 'api/json-schemata/ontology/proof_attempt' do
          expect(response.body).
            to match_json_schema(proof_attempt_schema)
        end
      end
    end
  end
end
