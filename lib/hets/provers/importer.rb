module Hets
  module Provers
    class Importer
      attr_accessor :ontology_version, :io

      # io needs to be an instance of IO or a Tempfile.
      def initialize(ontology_version, io)
        self.ontology_version = ontology_version
        self.io = io
      end

      def import
        hash = JSON.parse(io.read)
        provers = hash['provers']
        provers.each do |prover_hash|
          prover = Prover.where(prover_hash).first_or_create!
          unless ontology_version.provers.include?(prover)
            ontology_version.provers << prover
          end
        end
        ontology_version.save!
      end
    end
  end
end
