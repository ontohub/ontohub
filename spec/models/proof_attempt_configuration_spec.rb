require 'spec_helper'

describe ProofAttemptConfiguration do
  context 'Associations' do
    it { should belong_to(:prover) }
    it { should belong_to(:logic_mapping) }
    it { should have_many(:proof_attempts) }
    it { should have_and_belong_to_many(:axioms) }
    it { should have_and_belong_to_many(:goals) }
  end
end
