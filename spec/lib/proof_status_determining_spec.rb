require 'spec_helper'

describe 'Proof Status Determining', :http_interaction do
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

  let(:status_open) { create :proof_status_open }
  let(:status_csa) { create :proof_status_csa }
  let(:status_noc) { create :proof_status_disproven }
  let(:status_thm) { create :proof_status_proven }
  let(:axiom_selection) { create :manual_axiom_selection, axioms: [] }

  context 'with eprover' do
    let(:prover) { create :prover, name: 'eprover' }
    context 'on ontology: CounterSatisfiable' do
      let(:ontology) do
        parent_ontology.children.find_by_name('CounterSatisfiable')
      end
      let(:theorem) { ontology.theorems.original.first }
      let(:proof_attempt) do
        create :proof_attempt, theorem: theorem, prover: prover
      end
      let!(:proof_attempt_configuration) do
        pac = proof_attempt.proof_attempt_configuration
        pac.axiom_selection = axiom_selection.axiom_selection
        pac.prover = prover
        pac
      end

      it "proof_attempt's proof_status is OPN" do
        expect(proof_attempt.reload.proof_status).to eq(status_open)
      end

      context 'after proving' do
        before do
          generator.with_cassette(generate_cassette_name, :hets_prove_uri) do
            ProofExecution.new(proof_attempt).call
          end
        end

        it "proof_attempt's proof_status is CSA" do |example|
          expect(proof_attempt.reload.proof_status).to eq(status_csa)
        end
      end
    end

    context 'on ontology: Theorem' do
      let(:ontology) do
        parent_ontology.children.find_by_name('Theorem')
      end
      let(:theorem) { ontology.theorems.original.first }
      let(:proof_attempt) do
        create :proof_attempt, theorem: theorem, prover: prover
      end
      let!(:proof_attempt_configuration) do
        pac = proof_attempt.proof_attempt_configuration
        pac.axiom_selection = axiom_selection.axiom_selection
        pac.prover = prover
        pac
      end

      context 'after proving' do
        before do
          generator.with_cassette(generate_cassette_name, :hets_prove_uri) do
            ProofExecution.new(proof_attempt).call
          end
        end

        it "proof_attempt's proof_status is THM" do |example|
          expect(proof_attempt.reload.proof_status).to eq(status_thm)
        end
      end
    end
  end

  context 'with SPASS' do
    let(:prover) { create :prover, name: 'SPASS' }
    context 'on ontology: CounterSatisfiable' do
      let(:ontology) do
        parent_ontology.children.find_by_name('CounterSatisfiable')
      end
      let(:theorem) { ontology.theorems.original.first }
      let(:proof_attempt) do
        create :proof_attempt, theorem: theorem, prover: prover
      end
      let!(:proof_attempt_configuration) do
        pac = proof_attempt.proof_attempt_configuration
        pac.axiom_selection = axiom_selection.axiom_selection
        pac.prover = prover
        pac
      end

      context 'after proving' do
        before do
          generator.with_cassette(generate_cassette_name, :hets_prove_uri) do
            ProofExecution.new(proof_attempt).call
          end
        end

        it "proof_attempt's proof_status is NOC" do |example|
          expect(proof_attempt.reload.proof_status).to eq(status_noc)
        end
      end
    end

    context 'on ontology: Theorem' do
      let(:ontology) do
        parent_ontology.children.find_by_name('Theorem')
      end
      let(:theorem) { ontology.theorems.original.first }
      let(:proof_attempt) do
        create :proof_attempt, theorem: theorem, prover: prover
      end
      let!(:proof_attempt_configuration) do
        pac = proof_attempt.proof_attempt_configuration
        pac.axiom_selection = axiom_selection.axiom_selection
        pac.prover = prover
        pac
      end

      context 'after proving' do
        before do
          generator.with_cassette(generate_cassette_name, :hets_prove_uri) do
            ProofExecution.new(proof_attempt).call
          end
        end

        it "proof_attempt's proof_status is THM" do |example|
          expect(proof_attempt.reload.proof_status).to eq(status_thm)
        end
      end
    end
  end
end
