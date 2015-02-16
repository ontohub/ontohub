module Ontology::Validations
  extend ActiveSupport::Concern

  included do
    validates :iri, uniqueness: true, if: :iri_changed?
    validates :iri, format: {with: URI.regexp(Settings.allowed_iri_schemes)}

    validates :documentation,
      allow_blank: true,
      format: {with: URI.regexp(Settings.allowed_iri_schemes)}

    validates :basepath, presence: true

    validates :state, inclusion: {in: Ontology::States::STATES}
  end
end
