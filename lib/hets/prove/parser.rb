module Hets
  module Prove
    class Parser < JSONParser
      # possible hierarchy beginnings
      NODE = [:array, :object]
      GOAL = [*NODE, 'goals', :array, :object]
      TACTIC_SCRIPT = [*GOAL, 'tacticScript', :object]
      TACTIC_SCRIPT_EXTRA_OPTIONS = [*TACTIC_SCRIPT, 'extraOptions', :array]
      USED_TIME = [*GOAL, 'usedTime', :object]
      USED_TIME_COMPONENTS = [*USED_TIME, 'components', :object]
      USED_AXIOMS = [*GOAL, 'usedAxioms', :array]

      BRANCHES = %w(NODE GOAL TACTIC_SCRIPT TACTIC_SCRIPT_EXTRA_OPTIONS
                    USED_TIME USED_TIME_COMPONENTS USED_AXIOMS)

      protected

      def process_key(_key)
      end

      def process_value(value, key = nil)
        if key # value in object
          call_back(:set_object_value, :start, value, key)
        else # value in array
          call_back(:add_array_value, :start, value)
        end
      end

      def select_callback(order, *args)
        branch = BRANCHES.find do |const_name|
            hierarchy == constant(const_name)
          end
        if branch
          call_back(branch.downcase, order, *args)
        end
      end

      def constant(const_name)
        "#{self.class}::#{const_name}".constantize
      end
    end
  end
end
