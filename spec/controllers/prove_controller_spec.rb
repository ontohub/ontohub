require 'spec_helper'

describe ProveController do
  before { allow_any_instance_of(OntologyVersion).to receive(:async_prove) }
  let(:theorem) { create :theorem }
  let(:ontology) { theorem.ontology }
  let(:repository) { ontology.repository }

  context 'signed in with write access' do
    let(:user) { create(:permission, item: repository).subject }
    before { sign_in user }

    context 'create' do
      context 'with unproven theorems' do
        before do
          expect_any_instance_of(OntologyVersion).to receive(:async_prove)
          post :create,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param
        end

        it 'set the flash/success' do
          expect(flash[:success]).not_to be_nil
        end

        it { should respond_with :found }

        it 'redirect to the theorems view' do
          expect(response).to redirect_to([repository, ontology, :theorems])
        end
      end

      context 'without unproven theorems' do
        let(:proven) { create :proof_status_proven }
        let!(:proof_attempt) do
          create :proof_attempt, theorem: theorem, proof_status: proven
        end

        before do
          expect_any_instance_of(OntologyVersion).not_to receive(:async_prove)
          post :create,
            repository_id: repository.to_param,
            ontology_id: ontology.to_param
        end

        it 'set the flash/notice' do
          expect(flash[:notice]).not_to be_nil
        end

        it { should respond_with :found }

        it 'redirect to the theorems view' do
          expect(response).to redirect_to([repository, ontology, :theorems])
        end
      end
    end
  end

  context 'signed in, without write access' do
    let(:user) { create :user }
    before do
      sign_in user
      post :create,
        repository_id: repository.to_param,
        ontology_id: ontology.to_param
    end

    it 'set the flash/alert' do
      expect(flash[:alert]).to match(/not authorized/)
    end

    it 'redirect to the root path' do
      expect(response).to redirect_to(root_path)
    end
  end

  context 'not signed in' do
    let(:user) { create :user }
    before do
      sign_in user
      post :create,
        repository_id: repository.to_param,
        ontology_id: ontology.to_param
    end

    it 'set the flash/alert' do
      expect(flash[:alert]).to match(/not authorized/)
    end

    it 'redirect to the root path' do
      expect(response).to redirect_to(root_path)
    end
  end
end
