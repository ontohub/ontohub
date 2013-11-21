module Ontology::Tools
  extend ActiveSupport::Concern

  included do
    has_many :tools
  end

end
