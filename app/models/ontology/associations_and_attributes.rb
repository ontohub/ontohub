module Ontology::AssociationsAndAttributes
  extend ActiveSupport::Concern

  included do
    belongs_to :language
    belongs_to :logic, counter_cache: true
    belongs_to :ontology_type
    belongs_to :repository
    belongs_to :formality_level

    has_many :symbol_groups
    has_many :alternative_iris, dependent: :destroy
    has_many :source_mappings,
      class_name: 'Mapping', foreign_key: 'source_id', dependent: :destroy
    has_many :target_mappings,
      class_name: 'Mapping', foreign_key: 'target_id', dependent: :destroy
    has_many :tools

    has_and_belongs_to_many :license_models
    has_and_belongs_to_many :projects
    has_and_belongs_to_many :tasks

    attr_accessible :iri, :locid
    attr_accessible :name, :description, :acronym, :documentation,
                    :has_file,
                    :logic_id,
                    :category_ids,
                    :acronym,
                    :file_extension,
                    :projects,
                    :present,
                    :alternative_iris,
                    :ontology_type_id,
                    :license_model_ids,
                    :formality_level_id,
                    :task_ids,
                    :project_ids
  end
end
