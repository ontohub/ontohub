require 'spec_helper'

describe Theorem do
  context 'Associations' do
    it { should have_many(:proof_attempts) }
    it { should belong_to(:proof_status) }
  end

  context 'update_proof_status' do
    let(:success) { create :proof_status_success }
    let(:proven) { create :proof_status_proven }
    let(:unknown) { create :proof_status_unknown }

    context 'from solved status' do
      let(:theorem) { create :theorem, proof_status: success }

      context 'to solved status' do
        before { theorem.update_proof_status(proven) }

        it 'theorem has updated status' do
          expect(theorem.proof_status).to eq(proven)
        end
      end

      context 'to unsolved status' do
        before { theorem.update_proof_status(unknown) }

        it 'theorem still has previous status' do
          expect(theorem.proof_status).to eq(success)
        end
      end
    end

    context 'from unsolved status' do
      let(:theorem) { create :theorem, proof_status: unknown }

      context 'to solved status' do
        before { theorem.update_proof_status(proven) }

        it 'theorem has updated status' do
          expect(theorem.proof_status).to eq(proven)
        end
      end

      context 'to unsolved status' do
        before { theorem.update_proof_status(unknown) }

        it 'theorem has updated status' do
          expect(theorem.proof_status).to eq(unknown)
        end
      end
    end
  end
end
