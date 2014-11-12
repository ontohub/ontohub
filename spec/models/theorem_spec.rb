require 'spec_helper'

describe Theorem do
  context 'Validations' do
    context 'Status' do
      ProofAttempt::STATUSES.each do |proof_status|
        it "allow #{proof_status.inspect}" do
          should allow_value(proof_status).for(:proof_status)
        end
      end

      [nil, '', ' ', 'green'].each do |proof_status|
        it "not allow #{proof_status.inspect}" do
          should_not allow_value(proof_status).for(:proof_status)
        end
      end
    end
  end

  context 'update_proof_status' do
    context 'from decisive status' do
      let(:theorem) { create :theorem, proof_status: 'SOL' }

      context 'to decisive status' do
        before { theorem.update_proof_status('SAT') }

        it 'theorem has updated status' do
          expect(theorem.proof_status).to eq('SAT')
        end
      end

      context 'to non-decisive status' do
        before { theorem.update_proof_status('USD') }

        it 'theorem still has previous status' do
          expect(theorem.proof_status).to eq('SOL')
        end
      end
    end

    context 'from non-decisive status' do
      let(:theorem) { create :theorem, proof_status: 'UNK' }

      context 'to decisive status' do
        before { theorem.update_proof_status('SAT') }

        it 'theorem has updated status' do
          expect(theorem.proof_status).to eq('SAT')
        end
      end

      context 'to non-decisive status' do
        before { theorem.update_proof_status('USD') }

        it 'theorem has updated status' do
          expect(theorem.proof_status).to eq('USD')
        end
      end
    end
  end
end
