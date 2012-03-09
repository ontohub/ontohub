module Ontology::Axioms
  extend ActiveSupport::Concern

  included do
    has_many :axioms, :extend => Methods
  end

  module Methods
    def update_or_create_from_hash(hash)
      e = find_or_initialize_by_name(hash['name'])

      e.text  = hash['text'].to_s
      e.range = hash['range']

      e.save!

      execute_sql "DELETE FROM axioms_entities WHERE axiom_id=#{e.id}"
      execute_sql "INSERT INTO axioms_entities (axiom_id, entity_id, ontology_id)
                  SELECT #{e.id}, id, ontology_id FROM entities WHERE
                  ontology_id=#{@association.owner.id} AND text IN (?)",
                  hash['symbols']

      e
    end
  end
end
