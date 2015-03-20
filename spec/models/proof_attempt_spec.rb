require 'spec_helper'

describe ProofAttempt do
  context 'Associations' do
    it { should belong_to(:theorem) }
    it { should belong_to(:proof_status) }
  end

  let(:proof_attempt) { create :proof_attempt }

  context 'Updating Theorem Proof Status' do
    let(:proven) { create :proof_status_proven }
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

  context 'state' do
    it "is 'pending'" do
      expect(proof_attempt.state).to eq('pending')
    end
  end
end
