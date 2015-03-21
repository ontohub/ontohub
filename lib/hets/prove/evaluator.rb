module Hets
  module Prove
    class Evaluator
      attr_accessor :version, :path
      attr_accessor :ontology, :user, :proof_attempts
      attr_accessor :parser, :callback
      attr_accessor :now
      attr_accessor :io

      # As there are many approaches to parsing a proof,
      # we provide two versions:
      # new(user, ontology, version: some_version, io: some_io)
      # and
      # new(user, ontology, path: some_path, io: some_io)
      # where some_io needs to be an instance of IO or a Tempfile.
      def initialize(user, ontology, proof_attempts,
                     version: nil, path: nil, io: nil)
        self.version = version
        self.path = path
        self.ontology = ontology
        self.proof_attempts = proof_attempts
        self.user = user
        self.io = io
        initialize_handling
      end

      def import
        callback = ProveEvaluator.new(self, proof_attempts)
        ActiveRecord::Base.transaction requires_new: true do
          callback.process(:all, :start)
          parser.parse(callback: callback)
          callback.process(:all, :end)
        end
      end

      private
      def initialize_handling
        self.parser = Parser.new(io || path)
        self.now = Time.now
      end

      # The caller needs those methods to exists, but we don't need the
      # functionality here. This will be restructured in a later branch.
      %i(concurrency
        dgnode_stack
        dgnode_stack_id
        next_dgnode_stack_id).each do |method_name|
        define_method(method_name) {}
      end
    end
  end
end
