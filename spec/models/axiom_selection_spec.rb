require 'spec_helper'

describe AxiomSelection do
  let(:pa) { create :proof_attempt }
  let(:pac) { pa.proof_attempt_configuration }
  let(:axiom_selection) { pac.axiom_selection }
  subject { axiom_selection }

  context 'associations' do
    it { expect(subject).to have_many(:proof_attempt_configurations) }
    it { expect(subject).to have_and_belong_to_many(:axioms) }
  end

  context "methods that don't return nil" do
    %i(goal ontology).each do |method|
      it method do
        expect(subject.send(method)).not_to be(nil)
      end
    end
  end

  context 'lock_key' do
    it 'is correct' do
      expect(subject.lock_key).to eq("axiom-selection-#{subject.id}")
    end
  end
end
