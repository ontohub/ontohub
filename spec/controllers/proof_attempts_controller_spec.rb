require 'spec_helper'

describe ProofAttemptsController do
  let!(:proof_attempt) { create :proof_attempt }
  let!(:theorem) { proof_attempt.theorem }
  let!(:ontology) { theorem.ontology }
  let!(:repository) { ontology.repository }

  context 'signed in with read access' do
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
  end

  context 'signed in without read access on private repository' do
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
  end
end
