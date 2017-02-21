module Ontology::AssociationsAndAttributes
  extend ActiveSupport::Concern

  included do
    acts_as_tree
    # Add the scope "present: true" to the children association by acts_as_tree.
    Ontology.reflect_on_association(:children).
      options[:conditions] = {present: true}
    has_many :all_children, class_name: Ontology.to_s, foreign_key: 'parent_id'

    belongs_to :language
    belongs_to :logic, counter_cache: true
    belongs_to :ontology_type
    belongs_to :repository
    belongs_to :formality_level

    has_one :loc_id, foreign_key: :specific_id

    has_many :symbol_groups
    has_many :alternative_iris, dependent: :destroy
    has_many :source_mappings,
      class_name: 'Mapping', foreign_key: 'source_id', dependent: :destroy
    has_many :target_mappings,
      class_name: 'Mapping', foreign_key: 'target_id', dependent: :destroy
    has_many :tools

    has_many :symbols,
      autosave: false,
      class_name: 'OntologyMember::Symbol',
      extend:   Ontology::Symbols::Methods,
      dependent: :destroy

    has_many :sentences,
      autosave: false,
      extend: Ontology::Sentences::Methods,
      dependent: :destroy

    has_many :axioms,
      autosave: false,
      extend: Ontology::Sentences::Methods,
      dependent: :destroy

    has_many :theorems,
      autosave: false,
      extend: Ontology::Sentences::Methods,
      dependent: :destroy

    has_many :actions, as: :resource

    has_and_belongs_to_many :license_models
    has_and_belongs_to_many :projects
    has_and_belongs_to_many :tasks

    # Only used for locid generation.
    attr_accessor :externally_generated_locid

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
