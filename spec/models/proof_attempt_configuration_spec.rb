require 'spec_helper'

describe ProofAttemptConfiguration do
  context 'Associations' do
    it { should belong_to(:prover) }
    it { should belong_to(:logic_mapping) }
    it { should belong_to(:axiom_selection) }
    it { should have_one(:proof_attempt) }
  end

  context 'Methods' do
    let(:proof_attempt) { create :proof_attempt }
    let(:proof_attempt_configuration) do
      proof_attempt.proof_attempt_configuration
    end
    subject { proof_attempt_configuration }

    context 'empty?' do
      before do
        subject.timeout = nil
        subject.logic_mapping = nil
        subject.prover = nil
        subject.axiom_selection.axioms = []
      end

      it 'empty proof attempt configuration' do
        expect(subject.empty?).to be(true)
      end

      it 'with timeout set' do
        subject.timeout = 1
        expect(subject.empty?).to be(false)
      end

      it 'with logic_mapping set' do
        subject.logic_mapping = LogicMapping.first
        expect(subject.empty?).to be(false)
      end

      it 'with prover set' do
        subject.prover = Prover.first
        expect(subject.empty?).to be(false)
      end

      it 'with axiom_selection set' do
        create :axiom
        subject.axiom_selection.axioms = [Axiom.first]
        expect(subject.empty?).to be(false)
      end
    end
  end
end
