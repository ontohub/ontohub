module GraphStructures
  module SpecificFetchers
    module Mappings

      protected

      # Returns the logic_ids of the present ontologies
      # in the import-hierarchy (imported ontologies
      # and self). As this is a set, a size
      # of one represents that there are no logic translations.
      def contains_logic_translations_query(ontology)
        query, args = mappings_by_kind_query(ontology, 'import')
        full_query = <<-SQL.squish
          SELECT ? as logically_translated UNION
          SELECT ontologies.logic_id as logically_translated
          FROM ontologies
          JOIN (#{query}) as imported
          ON ontologies.id = imported.ontology_id
        SQL
        [full_query, [ontology.logic_id] + args]
      end

      def fetch_mappings_by_kind(ontology, kind)
        query, args = mappings_by_kind_query(ontology, kind)
        Ontology.where("id IN (#{query})", *args)
      end

      def mappings_by_kind_query(center, kind)
        query = <<-SQL.squish
          WITH RECURSIVE imported_ontologies(ontology_id) AS (
              SELECT source_id FROM mappings WHERE mappings.kind = ? AND mappings.target_id = ?
            UNION
              SELECT source_id FROM mappings
                JOIN imported_ontologies ON mappings.target_id = imported_ontologies.ontology_id
                WHERE mappings.kind = ?
          )
          SELECT ontology_id FROM imported_ontologies
        SQL
        [query, [kind, center, kind]]
      end

    end
  end
end
