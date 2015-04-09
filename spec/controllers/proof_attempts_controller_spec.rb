require 'spec_helper'

describe ProofAttemptsController do
  let!(:proof_attempt) { create :proof_attempt }
  let!(:theorem) { proof_attempt.theorem }
  let!(:ontology) { theorem.ontology }
  let!(:repository) { ontology.repository }

  context 'signed in with permissions' do
    let(:user) { create(:permission, item: repository).subject }
    before { sign_in user }

    context 'show' do
      before do
        get :show,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param,
          theorem_id: theorem.to_param,
          id: proof_attempt.to_param
      end
      it { should respond_with :success }
      it { should render_template :show }
    end

    context 'retry_failed' do
      before do
        allow_any_instance_of(ProofAttempt).to receive(:retry_failed)
        expect_any_instance_of(ProofAttempt).to receive(:retry_failed)
        proof_attempt.update_state!(:failed)
        post :retry_failed,
             repository_id: repository.to_param,
             ontology_id: ontology.to_param,
             theorem_id: theorem.to_param,
             id: proof_attempt.to_param
      end

      it 'redirect to the root path' do
        expect(response).to redirect_to(controllers_locid_for(proof_attempt))
      end

      it 'not set the flash' do
        expect(flash[:alert]).to be(nil)
      end
    end
  end

  context 'signed in without access on private repository' do
    let(:user) { create(:user) }
    before do
      repository.access = 'private_rw'
      repository.save!
      sign_in user
    end

    context 'show' do
      before do
        get :show,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param,
          theorem_id: theorem.to_param,
          id: proof_attempt.to_param
      end
      it { should respond_with :found }

      it 'set the flash/alert' do
        expect(flash[:alert]).to match(/not authorized/)
      end

      it 'redirect to the root path' do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'retry_failed' do
      before do
        allow_any_instance_of(ProofAttempt).to receive(:retry_failed)
        expect_any_instance_of(ProofAttempt).not_to receive(:retry_failed)
        proof_attempt.update_state!(:failed)
        post :retry_failed,
             repository_id: repository.to_param,
             ontology_id: ontology.to_param,
             theorem_id: theorem.to_param,
             id: proof_attempt.to_param
      end

      it 'set the flash/alert' do
        expect(flash[:alert]).to match(/not authorized/)
      end

      it 'redirect to the root path' do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  context 'not signed in' do
    context 'show' do
      before do
        get :show,
          repository_id: repository.to_param,
          ontology_id: ontology.to_param,
          theorem_id: theorem.to_param,
          id: proof_attempt.to_param
      end
      it { should respond_with :success }
      it { should render_template :show }
    end

    context 'retry_failed' do
      before do
        allow_any_instance_of(ProofAttempt).to receive(:retry_failed)
        expect_any_instance_of(ProofAttempt).not_to receive(:retry_failed)
        proof_attempt.update_state!(:failed)
        post :retry_failed,
             repository_id: repository.to_param,
             ontology_id: ontology.to_param,
             theorem_id: theorem.to_param,
             id: proof_attempt.to_param
      end

      it 'set the flash/alert' do
        expect(flash[:alert]).to match(/not authorized/)
      end

      it 'redirect to the root path' do
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
