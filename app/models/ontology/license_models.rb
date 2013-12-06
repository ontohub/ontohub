module Ontology::LicenseModels
  extend ActiveSupport::Concern

  included do
    has_many :license_models
  end

end
