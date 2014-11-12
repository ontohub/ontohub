require 'spec_helper'

describe ProofAttempt do
  context 'Validations' do
    context 'Status' do
      ProofAttempt::STATUSES.each do |status|
        it "allow #{status.inspect}" do
          should allow_value(status).for(:status)
        end
      end

      [nil, '', ' ', 'green'].each do |status|
        it "not allow #{status.inspect}" do
          should_not allow_value(status).for(:status)
        end
      end
    end
  end

  context 'decisive status' do
    %w(SOL SAT NOC SAB CSR).each do |status|
      it "#{status} is decisive" do
        expect(ProofAttempt.decisive_status?(status)).to be(true)
      end
    end

    %w(USD GUP Sln Non).each do |status|
      it "#{status} is not decisive" do
        expect(ProofAttempt.decisive_status?(status)).to be(false)
      end
    end
  end

  context 'Updating Theorem Proof Status' do
    let(:proof_attempt) { create :proof_attempt }
    let(:theorem) { proof_attempt.theorem }

    before do
      allow(theorem).to receive(:update_proof_status)
      proof_attempt.status = 'SOL'
      proof_attempt.save
    end

    it 'calls update_status on the theorem' do
      expect(theorem).to have_received(:update_proof_status)
    end
  end
end
