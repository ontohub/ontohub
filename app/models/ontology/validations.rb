module Ontology::Validations
  extend ActiveSupport::Concern

  included do

    validates :documentation,
      allow_blank: true,
      format: {with: URI.regexp(Settings.allowed_iri_schemes)}

    validates :basepath, presence: true

    validates :state, inclusion: {in: Ontology::States::STATES}
  end
end
