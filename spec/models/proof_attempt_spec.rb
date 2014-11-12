require 'spec_helper'

describe ProofAttempt do
  context 'Updating Theorem Proof Status' do
    let(:proof_attempt) { create :proof_attempt }
    let(:theorem) { proof_attempt.theorem }

    before do
      allow(theorem).to receive(:update_proof_status)
      proof_attempt.proof_status = ProofStatus.find('SOL')
      proof_attempt.save
    end

    it 'calls update_status on the theorem' do
      expect(theorem).to have_received(:update_proof_status)
    end
  end
end
