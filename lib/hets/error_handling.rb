module Hets
  module ErrorHandling

    def handle_hets_execution_error(error, ontology_version)
      if error.message.lines.last =~ /\*\*\* Error: unknown XML format/
        mark_as_non_ontology(ontology_version.ontology)
      end
    end

    def mark_as_non_ontology(ontology)
      ontology.destroy
    end

  end
end
