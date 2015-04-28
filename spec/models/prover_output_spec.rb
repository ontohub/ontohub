require 'spec_helper'

describe ProverOutput do
  context 'Associations' do
    it { should belong_to(:proof_attempt) }
  end
end
