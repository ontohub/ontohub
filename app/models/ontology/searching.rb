module Ontology::Searching
  extend ActiveSupport::Concern

  included do
    searchable do
      text :name
      text :entities do
        names = Array.new
        entities.each do |symbol|
          names.push symbol.display_name if symbol.display_name
          names.push symbol.name if symbol.name
          names.push symbol.text if symbol.text
        end
        names
      end
      text :logic do
        logic.name if logic
      end
      integer :ontology_type_id do
        ontology_type.id if ontology_type
      end
      integer :license_model_id do
        license_model.id if license_model
      end
      integer :formality_level_id do
        formality_level.id if formality_level
      end
      integer :task_id do
        task.id if task
      end
      integer :project_ids, multiple: true
      integer :repository_id
    end
  end

  module ClassMethods
    def search_by_keywords(keywords, page, qualifiers)
      Ontology.search do
        keywords.each { |keyword| fulltext keyword }
        with(:ontology_type_id, qualifiers[:ontology_type].id) if qualifiers[:ontology_type]
        with(:repository_id, qualifiers[:repository].id) if qualifiers[:repository]
        with(:license_model_id, qualifiers[:license_model].id) if qualifiers[:license_model]
        with(:formality_level_id, qualifiers[:formality_level].id) if qualifiers[:formality_level]
        with(:project_ids, [qualifiers[:project].id]) if qualifiers[:project]
        with(:task_id, qualifiers[:task].id) if qualifiers[:task]
        paginate page: page, per_page: 20
      end
    end
  end

end
