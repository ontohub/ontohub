module Hets
  module Prove
    module ProveEvaluationHelper
      def fill_proof_attempt_from_hash(proof_info)
        ontology = importer.ontology
        # The prove output of Hets may contain proofs for different ontologies.
        if correct_ontology?(ontology, proof_info)
          theorem = find_theorem_from_hash(proof_info, ontology)
          proof_attempt.do_or_set_failed(ProofEvaluationStateUpdater) do
            fill_proof_attempt_instance(proof_attempt, proof_info)
            proof_attempt.associate_prover_with_ontology_version
            create_prover_output(proof_attempt, proof_info)
            create_tactic_script(proof_attempt, proof_info)
            proof_attempt.save!
            ProofEvaluationStateUpdater.new(proof_attempt, :done).call
          end
        end
      end

      def fill_proof_attempt_instance(proof_attempt, proof_info)
        proof_attempt.proof_status = find_proof_status_from_hash(proof_info)
        proof_attempt.prover = find_or_create_prover_from_hash(proof_info)
        proof_attempt.time_taken = time_taken_from_hash(proof_info)
        used_axioms, used_theorems, generated_axioms =
          used_axioms_from_hash(proof_info, proof_attempt)
        proof_attempt.used_axioms = used_axioms
        proof_attempt.used_theorems = used_theorems
        proof_attempt.generated_axioms = generated_axioms
      end

      def find_theorem_from_hash(proof_info, ontology)
        ontology.theorems.original.find_by_name(proof_info[:theorem_name])
      end

      def find_proof_status_from_hash(proof_info)
        szs_parser = Hets::Prove::SZSParser.
          new(proof_info[:used_prover_identifier], proof_info[:prover_output])
        szs_name = szs_parser.call
        proof_status = ProofStatus.find_by_name(szs_name)
        proof_status ||= default_proof_status(proof_info)
        select_proof_status_on_axioms_subset(proof_status)
      end

      def default_proof_status(proof_info)
        identifier =
          case proof_info[:result]
          when 'Proved'
            ProofStatus::DEFAULT_PROVEN_STATUS
          when 'Disproved'
            ProofStatus::DEFAULT_DISPROVEN_STATUS
          when /Timeout/
            ProofStatus::DEFAULT_TIMEOUT_STATUS
          else
            ProofStatus::DEFAULT_UNKNOWN_STATUS
          end
        ProofStatus.find(identifier)
      end

      def select_proof_status_on_axioms_subset(proof_status)
        if proof_status.identifier == 'CSA' &&
          proof_attempt.proper_subset_of_axioms_selected?
          ProofStatus.find("#{proof_status.identifier}S")
        else
          proof_status
        end
      end

      def find_or_create_prover_from_hash(proof_info)
        name = proof_info[:used_prover_identifier]
        display_name = proof_info[:used_prover_name]
        Prover.where(name: name).
          first_or_create!(display_name: display_name)
      end

      def time_taken_from_hash(proof_info)
        if proof_info[:time_taken].to_i < 0
          0
        else
          proof_info[:time_taken]
        end
      end

      def create_tactic_script(proof_attempt, proof_info)
        if proof_info[:tactic_script_time_limit] &&
            proof_info[:tactic_script_extra_options]
          tactic_script = TacticScript.new
          tactic_script.proof_attempt = proof_attempt
          tactic_script.time_limit = proof_info[:tactic_script_time_limit].to_i
          tactic_script.extra_options =
            proof_info[:tactic_script_extra_options].map do |option|
            extra_option = TacticScriptExtraOption.new
            extra_option.option = option
            extra_option
          end
          tactic_script.save!
          tactic_script
        end
      end

      def used_axioms_from_hash(proof_info, proof_attempt)
        if proof_info[:used_axioms] && proof_attempt.theorem
          process_used_axioms(proof_info, proof_attempt)
        else
          [[], [], []]
        end
      end

      def process_used_axioms(proof_info, proof_attempt)
        used_axioms = []
        used_theorems = []
        generated_axioms = []
        proof_info[:used_axioms].each do |axiom_name|
          axiom = find_sentence_or_generate_axiom(axiom_name, proof_attempt)
          used_axioms << axiom if axiom.is_a?(Axiom)
          used_theorems << axiom if axiom.is_a?(Theorem)
          generated_axioms << axiom if axiom.is_a?(GeneratedAxiom)
        end
        [used_axioms, used_theorems, generated_axioms]
      end

      # Logic translations applied before proving can introduce new axioms that
      # are not stored as sentences in our database. They need to be
      # distinguished from sentences.
      def find_sentence_or_generate_axiom(axiom_name, proof_attempt)
        sentence = Sentence.
          where(ontology_id: proof_attempt.theorem.ontology.id,
                name: axiom_name).first
        sentence || generate_axiom(axiom_name, proof_attempt)
      end

      def generate_axiom(axiom_name, proof_attempt)
        generated_axiom = GeneratedAxiom.new
        generated_axiom.name = axiom_name
        generated_axiom.proof_attempt = proof_attempt
        generated_axiom.save
        generated_axiom
      end

      def create_prover_output(proof_attempt, proof_info)
        prover_output = ProverOutput.new
        prover_output.proof_attempt = proof_attempt
        prover_output.content = proof_info[:prover_output]
        prover_output.save!
      end

      def correct_ontology?(ontology, proof_info)
        ontology.name == proof_info[:ontology_name] ||
          proof_attempt.proof_attempt_configuration.prove_options.
            single_theorem_input_type?
      end
    end
  end
end
