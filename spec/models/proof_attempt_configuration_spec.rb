require 'spec_helper'

describe ProofAttemptConfiguration do
  context 'Associations' do
    it { should belong_to(:prover) }
    it { should belong_to(:logic_mapping) }
    it { should belong_to(:axiom_selection) }
    it { should have_one(:proof_attempt) }
  end
end
