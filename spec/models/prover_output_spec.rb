require 'spec_helper'

describe ProverOutput do
  context 'Associations' do
    it { expect(subject).to belong_to(:proof_attempt) }
  end
end
