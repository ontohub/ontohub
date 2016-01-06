class Ontology
  module ImportMappings
    extend ActiveSupport::Concern

    included do
      def is_imported?
        import_mappings.present?
      end

      def is_imported_from_other_repository?
        import_mappings_from_other_repositories.present?
      end

      def imported_by
        import_mappings.map(&:source)
      end

      def imported_ontologies
        fetch_mappings_by_kind(self, 'import')
      end

      def direct_imported_ontologies
        ontology_ids = Mapping.where(target_id: self, kind: 'import').
          pluck(:source_id)
        Ontology.where(id: ontology_ids)
      end

      protected

      def import_mappings
        Mapping.where(source_id: id, kind: 'import')
      end

      def import_mappings_from_other_repositories
        import_mappings.select { |l| l.target.repository != repository }
      end
    end
  end
end
