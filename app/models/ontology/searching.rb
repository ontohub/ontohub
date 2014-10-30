module Ontology::Searching
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    mapping do
      indexes :name, type: 'string', :analyzer => 'snowball'
      indexes :description, :analyzer => 'snowball'
    end

    scope :filter_by_ontology_type, ->(type_id) { where(ontology_type_id: type_id) }

    scope :filter_by_project, ->(project_id) do
      joins(:projects).where("projects.id = #{project_id}")
    end

    scope :filter_by_formality, ->(formality_id) do
      where(formality_level_id: formality_id)
    end

    scope :filter_by_license, ->(license_id) do
      joins(:license_models).where("license_models.id = #{license_id}")
    end

    scope :filter_by_task, ->(task_id) do
      joins(:tasks).where("tasks.id = #{task_id}")
    end
  end

end
