module Hets
  module Prove
    class Evaluator
      attr_accessor :version, :path
      attr_accessor :ontology, :user
      attr_accessor :parser, :callback
      attr_accessor :now
      attr_accessor :io

      # As there are many approaches to parsing a proof,
      # we provide two versions:
      # new(user, ontology, version: some_version, io: some_io)
      # and
      # new(user, ontology, path: some_path, io: some_io)
      # where some_io needs to be an instance of IO or a Tempfile.
      def initialize(user, ontology, version: nil, path: nil, io: nil)
        self.version = version
        self.path = path
        self.ontology = ontology
        self.user = user
        self.io = io
        initialize_handling
      end

      # Actually performs the import of the ontology file DGXML output.
      # Also calls the start and end callbacks, which do not actually
      # correspond to an element in the DGXML.
      def import
        callback = ProveEvaluator.new(self)
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

      %i(concurrency
        dgnode_stack
        dgnode_stack_id
        next_dgnode_stack_id).each do |method_name|
        define_method(method_name) {}
      end
    end
  end
end
