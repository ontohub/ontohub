require 'spec_helper'

describe AxiomSelection do
  context 'associations' do
    it { expect(subject).to have_one(:proof_attempt_configuration) }
    it { expect(subject).to have_and_belong_to_many(:axioms) }
  end
end
