module Hets
  module Prove
    module ProveEvaluationHelper
      def fill_proof_attempt_from_hash(proof_info)
        ontology = importer.ontology
        if ontology.name == proof_info[:ontology_name]
          theorem = find_theorem_from_hash(proof_info, ontology)
          proof_attempt = theorem.proof_attempts.
            where(id: proof_attempt_ids).first
          if proof_attempt
            proof_attempt.do_or_set_failed do
              fill_proof_attempt_instance(proof_attempt, proof_info)
              proof_attempt.associate_prover_with_ontology_version
              create_prover_output(proof_attempt, proof_info)
              create_tactic_script(proof_attempt, proof_info)
              proof_attempt.save!
              proof_attempt.update_state!(:done)
            end
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
        ontology.theorems.find_by_name(proof_info[:theorem_name])
      end

      def find_proof_status_from_hash(proof_info)
        identifier =
          case proof_info[:result]
          when 'Proved'
            ProofStatus::DEFAULT_PROVEN_STATUS
          when 'Disproved'
            ProofStatus::DEFAULT_DISPROVEN_STATUS
          else
            ProofStatus::DEFAULT_UNKNOWN_STATUS
          end
        ProofStatus.find(identifier)
      end

      def find_or_create_prover_from_hash(proof_info)
        name = proof_info[:used_prover_identifier]
        display_name = proof_info[:used_prover_name]
        Prover.where(name: name).
          first_or_create!(display_name: display_name)
      end

      def time_taken_from_hash(proof_info)
        if proof_info[:time_taken] < 0
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
    end
  end
end
