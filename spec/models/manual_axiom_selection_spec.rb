require 'spec_helper'

describe ManualAxiomSelection do
  let(:manual_axiom_selection) { create :manual_axiom_selection }

  context "respond to the parent's methods" do
    %i(proof_attempt_configuration axioms).each do |method|
      it method do
        expect(manual_axiom_selection).to respond_to(method)
      end
    end
  end
end

