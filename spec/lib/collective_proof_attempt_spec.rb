require 'spec_helper'

describe CollectiveProofAttempt do
  let(:theorem) { create :theorem }
  let(:ontology) { theorem.ontology }
  let(:prover1) { create :prover, :with_sequenced_name }
  let(:prover2) { create :prover, :with_sequenced_name }

  context 'no provers' do
    let(:cpa) { CollectiveProofAttempt.new(theorem, []) }

    it 'have a prove_options_list with one entry' do
      expect(cpa.prove_options_list.size).to eq(1)
    end

    it 'have a prove_options_list element with no specified prover' do
      expect(cpa.prove_options_list.first.options.has_key?(:prover)).
        to be(false)
    end
  end

  context 'two provers passed as IDs' do
    let(:cpa) do
      CollectiveProofAttempt.new(theorem, [prover1.to_param, prover2.to_param])
    end

    it 'have the two provers' do
      provers = cpa.prove_options_list.map do |prove_options|
        prove_options.options[:prover]
      end
      # We use .name because ProveOptions already converts it
      expect(provers).to eq([prover1.name, prover2.name])
    end
  end

  context 'two provers passed as objects' do
    let(:cpa) { CollectiveProofAttempt.new(theorem, [prover1, prover2]) }

    it 'have the two provers' do
      provers = cpa.prove_options_list.map do |prove_options|
        prove_options.options[:prover]
      end
      # We use .name because ProveOptions already converts it
      expect(provers).to eq([prover1.name, prover2.name])
    end

    context 'run' do
      let(:ontology_version) { cpa.send(:ontology_version) }
      before do
        allow(ontology_version).to receive(:update_state!).and_call_original
        allow(cpa.resource).to receive(:prove)
        cpa.run
      end

      it 'call prove with all options' do
        cpa.prove_options_list.each do |prove_options|
          expect(cpa.resource).to have_received(:prove).with(prove_options)
        end
      end

      it 'update ontology_version state to processing' do
        expect(ontology_version).
          to have_received(:update_state!).with(:processing)
      end

      it 'update ontology_version state to done' do
        expect(ontology_version).
          to have_received(:update_state!).with(:done)
      end
    end
  end
end
