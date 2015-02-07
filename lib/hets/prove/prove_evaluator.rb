module Hets
  module Prove
    class ProveEvaluator < BaseEvaluator
      attr_accessor :object_hash, :hierarchy

      register :all, :start, to: :all_start
      register :all, :end, to: :all_end

      register :set_object_value, :start, to: :set_object_value
      register :add_array_value, :start, to: :add_array_value

      register :node, :start, to: :node_start
      register :node, :end, to: :node_end

      register :goal, :start, to: :goal_start
      register :goal, :end, to: :goal_end

      register :tactic_script, :start, to: :tactic_script_start
      register :tactic_script, :end, to: :tactic_script_end

      register :tactic_script_extra_options, :start,
        to: :tactic_script_extra_options_start
      register :tactic_script_extra_options, :end,
        to: :tactic_script_extra_options_end

      register :used_time, :start, to: :used_time_start
      register :used_time, :end, to: :used_time_end

      register :used_time_components, :start, to: :used_time_components_start
      register :used_time_components, :end, to: :used_time_components_end

      register :used_axioms, :start, to: :used_axioms_start
      register :used_axioms, :end, to: :used_axioms_end

      def create_proof_attempt_from_hash(hash)
        ontology = hets_evaluator.ontology
        if ontology.name == hash[:ontology_name]
          proof_attempt = ProofAttempt.new
          proof_attempt.theorem = theorem_from_hash(hash, ontology)
          proof_attempt.proof_status = proof_status_from_hash(hash)
          proof_attempt.prover = hash[:used_prover]
          proof_attempt.prover_output = hash[:prover_output]
          proof_attempt.time_taken = hash[:time_taken]
          proof_attempt.tactic_script = tactic_script_from_hash(hash)
          proof_attempt.used_axioms = used_axioms_from_hash(hash, proof_attempt)

          proof_attempt.save!
        end
      end

      def theorem_from_hash(hash, ontology)
        ontology.theorems.find_by_name(hash[:theorem_name])
      end

      def proof_status_from_hash(hash)
        identifier =
          case hash[:result]
          when 'Proved'
            ProofStatus::DEFAULT_PROVEN_STATUS
          when 'Disproved'
            ProofStatus::DEFAULT_DISPROVEN_STATUS
          else
            ProofStatus::DEFAULT_UNKNOWN_STATUS
          end
        ProofStatus.find(identifier)
      end

      def tactic_script_from_hash(hash)
        {
          time_limit: hash[:tactic_script_time_limit],
          extra_options: hash[:tactic_script_extra_options],
        }.to_json
      end

      def used_axioms_from_hash(hash, proof_attempt)
        if hash[:used_axioms] && proof_attempt.theorem
          hash[:used_axioms].map do |axiom_name|
            ontology = proof_attempt.theorem.ontology
            # We need the `unscoped` call to include theorems.
            Sentence.unscoped.
              where(ontology_id: ontology.to_param, name: axiom_name).first
          end
        else
          []
        end
      end

      def all_start
        self.hierarchy = []
      end

      def all_end
      end

      def set_object_value(value, key)
        info = proof_attempt_info(key, value)
        object_hash[info.keys.first] = info.values.first if info
      end

      def add_array_value(value)
        info = proof_attempt_info
        object_hash[info.keys.first] ||= []
        object_hash[info.keys.first] << value
      end

      def node_start
        hierarchy << :node
        self.object_hash = {}
      end

      def node_end
        hierarchy.pop
      end

      def goal_start
        hierarchy << :goal
        ontology_name = object_hash[:ontology_name]
        self.object_hash = {ontology_name: ontology_name}
      end

      def goal_end
        hierarchy.pop
        create_proof_attempt_from_hash(object_hash)
      end

      %i(tactic_script
        tactic_script_extra_options
        used_time
        used_time_components
        used_axioms).each do |hook|
        define_method("#{hook}_start") do
          hierarchy << hook
        end

        define_method("#{hook}_end") do
          hierarchy.pop
        end
      end

      def proof_attempt_info(key = nil, value = nil)
        case hierarchy.last
        when :node
          {ontology_name: value} if key == 'node'
        when :goal
          goal_info(key, value)
        when :tactic_script
          {:"tactic_script_#{key.underscore}" => value}
        when :tactic_script_extra_options
          {:tactic_script_extra_options => nil}
        when :used_time
          {:time_taken => value} if key == 'seconds'
        when :used_time_components
          # don't use them
        when :used_axioms
          {:used_axioms => nil}
        else
          {key.underscore.to_sym => value}
        end
      end

      def goal_info(key, value)
        if key == 'name'
          {:theorem_name => value}
        else
          {key.underscore.to_sym => value}
        end
      end

      def initiate_concurrency_handling
        # overwrite this method - concurrency is not an issue here
      end

      def finish_concurrency_handling
        # overwrite this method - concurrency is not an issue here
      end

      def cancel_concurrency_handling_on_error
        # overwrite this method - concurrency is not an issue here
      end
    end
  end
end
