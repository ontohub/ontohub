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
      integer :repository_id
    end
  end

  module ClassMethods
    def search_by_keywords(keywords, page, repository, project, ontology_type, license_model, formality_level, task)
      Ontology.search do
        keywords.each { |keyword| fulltext keyword }
        with(:ontology_type_id, ontology_type.id) unless ontology_type.nil?
        with(:repository_id, repository.id) unless repository.nil?
        with(:license_model_id, license_model.id) unless license_model.nil?
        with(:formality_level_id, formality_level.id) unless formality_level.nil?
        with(:task_id, task.id) unless task.nil?
        paginate page: page, per_page: 20
      end
    end
  end

end
