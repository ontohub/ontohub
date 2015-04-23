module Hets
  module Provers
    class Importer
      ALLOWED_KEYS = %w(name display_name)
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
          prover_hash.select! { |k, _v| ALLOWED_KEYS.include?(k) }
          prover = Prover.where(name: prover_hash.delete('name')).
            first_or_create!
          prover.update_attributes!(prover_hash)
          unless ontology_version.provers.include?(prover)
            ontology_version.provers << prover
          end
        end
        ontology_version.save!
      end
    end
  end
end
