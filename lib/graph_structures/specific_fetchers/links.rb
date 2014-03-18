module GraphStructures
  module SpecificFetchers
    module Links

      protected
      def fetch_links_by_kind(ontology, kind)
        query, args = links_by_kind_query(ontology, kind)
        Ontology.where("id IN (#{query})", *args)
      end

      def links_by_kind_query(center, kind)
        query = <<-SQL
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
