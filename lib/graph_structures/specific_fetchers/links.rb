module GraphStructures
  module SpecificFetchers
    module Links

      protected

      # Returns the logic_ids of the present ontologies
      # in the import-hierarchy (imported ontologies
      # and self). As this is a set, a size
      # of one represents that there are no logic translations.
      def contains_logic_translations_query(ontology)
        query, args = links_by_kind_query(ontology, 'import')
        full_query = <<-SQL.squish
          SELECT ? as logically_translated UNION
          SELECT ontologies.logic_id as logically_translated
          FROM ontologies
          JOIN (#{query}) as imported
          ON ontologies.id = imported.ontology_id
        SQL
        [full_query, [ontology.logic_id] + args]
      end

      def fetch_links_by_kind(ontology, kind)
        query, args = links_by_kind_query(ontology, kind)
        Ontology.where("id IN (#{query})", *args)
      end

      def links_by_kind_query(center, kind)
        query = <<-SQL.squish
          WITH RECURSIVE imported_ontologies(ontology_id) AS (
              SELECT source_id FROM links WHERE links.kind = ? AND links.target_id = ?
            UNION
              SELECT source_id FROM links
                JOIN imported_ontologies ON links.target_id = imported_ontologies.ontology_id
                WHERE links.kind = ?
          )
          SELECT ontology_id FROM imported_ontologies
        SQL
        [query, [kind, center, kind]]
      end

    end
  end
end
