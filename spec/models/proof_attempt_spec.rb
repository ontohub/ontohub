require 'spec_helper'

describe ProofAttempt do
  context 'Associations' do
    it { should belong_to(:theorem) }
    it { should belong_to(:proof_status) }
  end

  context 'Updating Theorem Proof Status' do
    let(:proven) { create :proof_status_proven }
    let(:proof_attempt) { create :proof_attempt }
    let(:theorem) { proof_attempt.theorem }

    before do
      allow(theorem).to receive(:update_proof_status)
      proof_attempt.proof_status = proven
      proof_attempt.save!
    end

    it 'calls update_status on the theorem' do
      expect(theorem).to have_received(:update_proof_status)
    end
  end
end
