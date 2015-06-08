require 'spec_helper'

describe 'CollectiveProofAttempt - Axiom Selection', :http_interaction do
  setup_hets

  let(:user) { create :user }
  let(:repository) { create :repository }

  let(:ontology_fixture_file) { %w(prove/Simple_Implications casl) }
  let(:ontology_filepath) { ontology_fixture_file.join('.') }

  let(:generator) do
    FixturesGeneration::PipelineGenerator.new
  end

  before { stub_hets_for(ontology_filepath) }

  let(:parent_ontology_version) do
    version = version_for_file(repository,
                               ontology_file(*ontology_fixture_file))
    version.parse
    version
  end

  let(:parent_ontology) { parent_ontology_version.ontology }

  let(:ontology) do
    parent_ontology.children.find_by_name('Group')
  end
  let(:theorem) { ontology.theorems.find_by_name('rightunit') }
  let(:axioms) { ontology.axioms }

  let(:prover) { create :prover }
  let(:status_disproven) { create :proof_status_disproven }
  let(:status_proven) { create :proof_status_proven }

  let(:proof_attempt) do
    create :proof_attempt, theorem: theorem, prover: prover
  end

  context 'all axioms' do
    let(:options) do
      Hets::ProveOptions.new(prover: prover, axioms: axioms)
    end
    let(:options_to_attempts) { {options => [proof_attempt]} }
    let(:cpa) { CollectiveProofAttempt.new(theorem, options_to_attempts) }

    before do
      generator.with_cassette(generate_cassette_name, :hets_prove_uri) do
        cpa.run
      end
    end

    it 'proven' do |example|
      expect(proof_attempt.reload.proof_status).to eq(status_proven)
    end
  end

  context 'no axioms (meaning all are used)' do
    let(:options) do
      Hets::ProveOptions.new(prover: prover, axioms: [])
    end
    let(:options_to_attempts) { {options => [proof_attempt]} }
    let(:cpa) { CollectiveProofAttempt.new(theorem, options_to_attempts) }

    before do
      generator.with_cassette(generate_cassette_name, :hets_prove_uri) do
        cpa.run
      end
    end

    it 'proven' do |example|
      expect(proof_attempt.reload.proof_status).to eq(status_proven)
    end
  end

  context 'not sufficient axioms' do
    let(:options) do
      Hets::ProveOptions.new(prover: prover, axioms: [axioms.first])
    end
    let(:options_to_attempts) { {options => [proof_attempt]} }
    let(:cpa) { CollectiveProofAttempt.new(theorem, options_to_attempts) }

    before do
      generator.with_cassette(generate_cassette_name, :hets_prove_uri) do
        cpa.run
      end
    end

    it 'disproven' do |example|
      expect(proof_attempt.reload.proof_status).to eq(status_disproven)
    end
  end
end
