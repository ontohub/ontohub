module Ontology::Validations
  extend ActiveSupport::Concern

  included do
    validates_uniqueness_of :iri, if: :iri_changed?
    validates_format_of :iri, with: URI::regexp(Settings.allowed_iri_schemes)

    validates :documentation,
      allow_blank: true,
      format: { with: URI::regexp(Settings.allowed_iri_schemes) }

    validates_presence_of :basepath

    validates_inclusion_of :state, in: Ontology::States::STATES
  end
end
