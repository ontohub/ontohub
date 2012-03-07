module Ontology::Axioms
  extend ActiveSupport::Concern

  included do
    has_many :axioms, :extend => Methods
  end

  module Methods
    def update_or_create_from_hash(hash)
      e = find_or_create_by_text(hash['text'])

      execute "DELETE FROM axioms_entities WHERE axiom_id=#{e.id}"
      execute "INSERT INTO axioms_entities (axiom_id, entity_id)
               SELECT #{e.id}, id FROM entities WHERE
               ontology_id=#{proxy_owner.id} AND text IN (?)",
               hash['symbols']
    end
  end
end
