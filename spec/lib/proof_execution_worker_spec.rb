require 'spec_helper'

describe ProofExecutionWorker do
  let(:pew) { ProofExecutionWorker.new }
  subject { pew }

  let!(:proof_attempt) { create :proof_attempt }

  context 'Methods' do
    context 'perform calls a ProofExecution' do
      before do
        allow_any_instance_of(ProofExecution).to receive(:call)
        allow(ProofExecution).to receive(:new).and_call_original
        expect(ProofExecution).to receive(:new).once.with(proof_attempt)
      end

      it 'works' do
        subject.perform(proof_attempt.id)
      end
    end

    context 'perform creates a ProofExecution with a ProofAttempt object' do
      before do
        allow_any_instance_of(ProofExecution).to receive(:call)
        allow(ProofExecution).to receive(:new).and_call_original
        expect_any_instance_of(ProofExecution).to receive(:call).once
      end

      it 'works' do
        subject.perform(proof_attempt.id)
      end
    end
  end
end
