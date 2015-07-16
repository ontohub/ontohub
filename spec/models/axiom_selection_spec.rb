require 'spec_helper'

describe AxiomSelection do
  let(:axiom_selection) { create :axiom_selection }
  subject { axiom_selection }

  context 'associations' do
    it { expect(subject).to have_many(:proof_attempt_configurations) }
    it { expect(subject).to have_and_belong_to_many(:axioms) }
  end

  context 'lock_key' do
    it 'is correct' do
      expect(subject.lock_key).to eq("axiom-selection-#{subject.id}")
    end
  end
end
