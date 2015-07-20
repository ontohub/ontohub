module Hets
  module Prove
    class Importer
      attr_accessor :version, :path
      attr_accessor :ontology, :user, :proof_attempt
      attr_accessor :parser, :callback
      attr_accessor :now
      attr_accessor :io

      # As there are many approaches to parsing a proof,
      # we provide two versions:
      # new(user, ontology, version: some_version, io: some_io)
      # and
      # new(user, ontology, path: some_path, io: some_io)
      # where some_io needs to be an instance of IO or a Tempfile.
      def initialize(user, ontology, proof_attempt,
                     version: nil, path: nil, io: nil)
        self.version = version
        self.path = path
        self.ontology = ontology
        self.proof_attempt = proof_attempt
        self.user = user
        self.io = io
        initialize_handling
      end

      def import
        callback = ProveEvaluator.new(self, proof_attempt)
        ActiveRecord::Base.transaction requires_new: true do
          callback.process(:all, :start)
          parser.parse(callback: callback)
          callback.process(:all, :end)
        end
      rescue Hets::JSONParser::ParserError => e
        io.rewind
        if io.read(16) == 'nothing to prove'
          pa_configuration = proof_attempt.proof_attempt_configuration
          msg_lines = ['Hets found no theorems to prove']
          msg_lines << "Configuration: #{pa_configuration.inspect}"
          raise Hets::Errors::HetsFileError, msg_lines.join("\n")
        else
          raise
        end
      end

      private
      def initialize_handling
        self.parser = Parser.new(io || path)
        self.now = Time.now
      end
    end
  end
end
