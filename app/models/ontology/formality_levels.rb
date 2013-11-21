module Ontology::FormalityLevels
  extend ActiveSupport::Concern

  included do
    has_many :formality_levels
  end

end
