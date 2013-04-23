module Ontology::Categories
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :categories#, :extend => Methods

    attr_accessible :category_id, :name
  end

end
