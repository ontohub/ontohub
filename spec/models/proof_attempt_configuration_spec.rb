require 'spec_helper'

describe ProofAttemptConfiguration do
  context 'Associations' do
    it { expect(subject).to belong_to(:prover) }
    it { expect(subject).to belong_to(:logic_mapping) }
    it { expect(subject).to have_many(:proof_attempts) }
    it { expect(subject).to have_and_belong_to_many(:axioms) }
    it { expect(subject).to have_and_belong_to_many(:goals) }
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
