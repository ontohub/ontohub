require 'spec_helper'

describe AxiomSelection do
  let(:axiom_selection) { create :axiom_selection }
  subject { axiom_selection }

  context 'associations' do
    it { expect(subject).to have_one(:proof_attempt_configuration) }
    it { expect(subject).to have_and_belong_to_many(:axioms) }
  end
end
