module Ontology::LicenseModels
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :license_models
  end

end
