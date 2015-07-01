require 'spec_helper'

describe AxiomSelection do
  context 'associations' do
    it { should have_one(:proof_attempt_configuration) }
    it { should have_and_belong_to_many(:axioms) }
  end
end
