module Ontology::Entities
  extend ActiveSupport::Concern

  included do
    has_many :entities, :extend => Methods
  end

  module Methods
    def update_or_create_from_hash(hash)
      e = find_or_initialize_by_text(hash['text'])

      e.ontology = @association.owner

      e.name = hash['name']
      e.range = hash['range']
      e.kind = hash['kind']

      e.save
    end
  end
end
