module Hets
  class Evaluator
    attr_accessor :version, :path
    attr_accessor :ontology, :user, :ontologies_count
    attr_accessor :parser, :callback
    attr_accessor :concurrency, :dgnode_stack, :ontology_aliases
    attr_accessor :versions, :now, :dgnode_count
    attr_accessor :io

    # As there are many approaches to parsing an ontology
    # file, we provide two versions:
    # new(user, ontology, version: some_version, io: some_io)
    # and
    # new(user, ontology, path: some_path, io: some_io)
    # where some_io needs to be an instance of IO or a Tempfile.
    # version object.
    def initialize(user, ontology, version: nil, path: nil, io: nil)
      self.version = version
      self.path = path
      self.ontology = ontology
      self.user = user
      self.ontologies_count = 0
      self.io = io
      initialize_handling
    end

    # Actually performs the import of the ontology file DGXML output.
    # Also calls the start and end callbacks, which do not actually
    # correspond to an element in the DGXML.
    def import
      callback = NodeEvaluator.new(self)
      ActiveRecord::Base.transaction requires_new: true do
        callback.process(:all, :start)
        parser.parse(callback: callback)
        callback.process(:all, :end)
      end
    end

    def ontologies
      versions.map(&:ontology)
    end

    def next_dgnode_stack_id
      dgnode_stack.length
    end

    def dgnode_stack_id
      next_dgnode_stack_id - 1
    end

    private
    def initialize_handling
      self.parser = Parser.new(io || path)
      self.concurrency = ConcurrencyBalancer.new
      self.versions = []
      self.dgnode_stack = []
      self.ontology_aliases = {}
      self.now = Time.now
    end

  end
end
