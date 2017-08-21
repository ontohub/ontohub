module Repository::AssociationsAndAttributes
  extend ActiveSupport::Concern

  included do
      has_many :ontologies, dependent: :destroy
      has_many :ontology_versions, through: :ontologies
      has_many :url_maps, dependent: :destroy
      has_many :commits, dependent: :destroy
      has_many :access_tokens, dependent: :destroy

      attr_accessible :name,
                      :description,
                      :source_type,
                      :source_address,
                      :remote_type,
                      :access,
                      :featured,
                      :destroy_job_id,
                      :is_destroying
  end
end
