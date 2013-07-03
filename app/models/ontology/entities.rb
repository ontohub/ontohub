module Ontology::Entities
  extend ActiveSupport::Concern

  included do
    has_many :entities, :extend => Methods
  end

  module Methods
    def update_or_create_from_hash(hash, timestamp = Time.now)
      raise ArgumentError, 'No hash given.' unless hash.is_a? Hash

      e = find_or_initialize_by_text(hash['text'])

      e.ontology = @association.owner
      e.name       = hash['name'] || hash['text']
      e.range      = hash['range']
      e.kind       = hash['kind'] || 'Undefined'
      e.updated_at = timestamp
      
      if e.range.to_s.include?(":")
        # remove path from range
        # Examples/Reichel:28.9 -> 28.9
        e.range = e.range.split(":",2).last
      end

      e.save!
    end
  end
end
