require 'spec_helper'

describe 'Axiom Selection: Proof Status', :http_interaction do
  setup_hets
  stub_fqdn_and_port_for_pipeline_generator
  let(:generator) do
    FixturesGeneration::PipelineGenerator.new
  end

  let(:user) { create :user }
  let(:repository) { create :repository }

  let(:ontology_fixture_file) { %w(prove/Simple_Implications casl) }
  let(:ontology_filepath) { ontology_fixture_file.join('.') }

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
  let(:theorem) { ontology.theorems.original.find_by_name('rightunit') }
  let(:axioms) { ontology.axioms }

  let(:prover) { create :prover }
  let(:status_disproven) { create :proof_status_disproven }
  let(:status_disproven_on_subset) { create :proof_status_csas }
  let(:status_proven) { create :proof_status_proven }

  context 'all axioms' do
    let(:axiom_selection) { create :manual_axiom_selection, axioms: axioms }
    let(:proof_attempt) do
      create :proof_attempt, theorem: theorem, prover: prover
    end
    let!(:proof_attempt_configuration) do
      pac = proof_attempt.proof_attempt_configuration
      pac.axiom_selection = axiom_selection.axiom_selection
      pac.prover = prover
      pac
    end

    before do
      generator.with_cassette(generate_cassette_name, :hets_prove_uri) do
        ProofExecution.new(proof_attempt).call
      end
    end

    it 'proven' do |example|
      expect(proof_attempt.reload.proof_status).to eq(status_proven)
    end
  end

  context 'no axioms (meaning all are used)' do
    let(:axiom_selection) { create :manual_axiom_selection, axioms: [] }
    let(:proof_attempt) do
      create :proof_attempt, theorem: theorem, prover: prover
    end
    let!(:proof_attempt_configuration) do
      pac = proof_attempt.proof_attempt_configuration
      pac.axiom_selection = axiom_selection.axiom_selection
      pac.prover = prover
      pac
    end

    before do
      generator.with_cassette(generate_cassette_name, :hets_prove_uri) do
        ProofExecution.new(proof_attempt).call
      end
    end

    it 'proven' do |example|
      expect(proof_attempt.reload.proof_status).to eq(status_proven)
    end
  end

  context 'not sufficient axioms' do
    let(:axiom_selection) do
      create :manual_axiom_selection, axioms: [axioms.first]
    end
    let(:proof_attempt) do
      create :proof_attempt, theorem: theorem, prover: prover
    end
    let!(:proof_attempt_configuration) do
      pac = proof_attempt.proof_attempt_configuration
      pac.axiom_selection = axiom_selection.axiom_selection
      pac.prover = prover
      pac
    end

    before do
      generator.with_cassette(generate_cassette_name, :hets_prove_uri) do
        ProofExecution.new(proof_attempt).call
      end
    end

    it 'disproven on subset' do |example|
      expect(proof_attempt.reload.proof_status).to eq(status_disproven_on_subset)
    end
  end
end
