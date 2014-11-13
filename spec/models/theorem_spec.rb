require 'spec_helper'

describe Theorem do
  context 'Associations' do
    it { should have_many(:proof_attempts) }
    it { should belong_to(:proof_status) }
  end

  context 'update_proof_status' do
    context 'from decisive status' do
      let(:theorem) { create :theorem, proof_status: ProofStatus.find('SOL') }

      context 'to decisive status' do
        before { theorem.update_proof_status(ProofStatus.find('SAT')) }

        it 'theorem has updated status' do
          expect(theorem.proof_status).to eq(ProofStatus.find('SAT'))
        end
      end

      context 'to non-decisive status' do
        before { theorem.update_proof_status(ProofStatus.find('USD')) }

        it 'theorem still has previous status' do
          expect(theorem.proof_status).to eq(ProofStatus.find('SOL'))
        end
      end
    end

    context 'from non-decisive status' do
      let(:theorem) { create :theorem, proof_status: ProofStatus.find('UNK') }

      context 'to decisive status' do
        before { theorem.update_proof_status(ProofStatus.find('SAT')) }

        it 'theorem has updated status' do
          expect(theorem.proof_status).to eq(ProofStatus.find('SAT'))
        end
      end

      context 'to non-decisive status' do
        before { theorem.update_proof_status(ProofStatus.find('USD')) }

        it 'theorem has updated status' do
          expect(theorem.proof_status).to eq(ProofStatus.find('USD'))
        end
      end
    end
  end
end
