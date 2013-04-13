module Ontology::Categories
  extend ActiveSupport::Concern

  included do
    has_many :categories#, :extend => Methods
  end
end
