require 'spec_helper'

describe ProofAttemptConfiguration do
  context 'Associations' do
    it { should belong_to(:prover) }
    it { should belong_to(:logic_mapping) }
    it { should have_one(:proof_attempt) }
  end

  context 'locid' do
    let(:pac) { create :proof_attempt_configuration }
    let(:ontology) { pac.ontology }

    it 'has the correct locid' do
      expect(pac.locid).
        to eq("#{ontology.locid}//proof-attempt-configuration-#{pac.number}")
    end
  end
end
