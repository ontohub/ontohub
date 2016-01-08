class Ontology
  # An ontology being imported into is in this context not only a Mapping with
  # kind 'import' but any kind of mapping. Otherwise the target ontology's view,
  # alignment, etc. is invalid.
  module ImportMappings
    extend ActiveSupport::Concern

    included do
      def is_imported_from_other_repository?
        import_mappings_from_other_repositories.present?
      end

      def is_imported_from_other_file?
        import_mappings_from_other_files.present?
      end

      def mapping_targets
        source_mappings.map(&:target)
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

      def import_mappings_from_other_files
        source_mappings.reject do |l|
          l.target.repository == repository && l.target.path == path
        end
      end

      def import_mappings_from_other_repositories
        source_mappings.select { |l| l.target.repository != repository }
      end
    end
  end
end
