module Repository::AssociationsAndAttributes
  extend ActiveSupport::Concern

  included do
      has_many :ontologies, dependent: :destroy
      has_many :url_maps, dependent: :destroy
      has_many :commits, dependent: :destroy

      attr_accessible :name,
                      :description,
                      :source_type,
                      :source_address,
                      :remote_type,
                      :access,
                      :destroy_job_id,
                      :is_destroying
  end
end
