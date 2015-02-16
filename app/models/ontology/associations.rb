module Ontology::Associations
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
  end
end