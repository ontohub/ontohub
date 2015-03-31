require 'spec_helper'

describe Proof do
  let(:prover) { create :prover }
  let(:theorem) { create :theorem }
  let(:ontology) { theorem.ontology }
  let(:ontology_version) { ontology.current_version }
  let(:repository) { ontology.repository }
  let(:params) do
    {
      repository_id: repository.to_param,
      ontology_id: ontology.to_param,
      proof: {provers: [prover.to_param.to_s, '']},
    }
  end

  context 'validations' do
    it 'is valid' do
      expect(Proof.new(params).valid?).to be(true)
    end

    it 'is not valid with bad provers' do
      bad_params = params.merge({proof: {provers: ['-1', '']}})
      expect(Proof.new(bad_params).valid?).to be(false)
    end
  end

  context 'usage for ontology_version' do
    let(:proof) { Proof.new(params) }

    it 'has IDs as provers' do
      proof.provers.each do |prover|
        expect(prover).to be > 0
      end
    end

    it 'has the ontology_version as proof obligation' do
      expect(proof.proof_obligation).to eq(ontology_version)
    end

    it 'starts proving on save!' do
      allow(CollectiveProofAttemptWorker).to receive(:perform_async)
      proof.save!
      expect(CollectiveProofAttemptWorker).
        to have_received(:perform_async).
        with(OntologyVersion.to_s, ontology_version.id, proof.provers)
    end
  end

  context 'usage for theorem' do
    let(:theorem_params) { params.merge(theorem_id: theorem.to_param) }
    let(:proof) { Proof.new(theorem_params) }

    it 'has the theorem as proof obligation' do
      expect(proof.proof_obligation).to eq(theorem)
    end

    it 'starts proving on save!' do
      allow(CollectiveProofAttemptWorker).to receive(:perform_async)
      proof.save!
      expect(CollectiveProofAttemptWorker).
        to have_received(:perform_async).
        with(Theorem.to_s, theorem.id, proof.provers)
    end
  end
end
