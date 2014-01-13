module Ontology::Sentences
  extend ActiveSupport::Concern

  included do
    has_many :sentences,
      autosave: false,
      extend:   Methods
  end

  module Methods
    def update_or_create_from_hash(hash, timestamp = Time.now)
      e = find_or_initialize_by_name(hash['name'])

      e.text       = hash['text'].to_s
      e.range      = hash['range']
      e.updated_at = timestamp

      e.save!
      
      execute_sql "DELETE FROM entities_sentences WHERE sentence_id=#{e.id}"
      execute_sql "INSERT INTO entities_sentences (sentence_id, entity_id, ontology_id)
                  SELECT #{e.id}, id, ontology_id FROM entities WHERE
                  ontology_id=#{@association.owner.id} AND text IN (?)",
                  hash['symbols']

      e.set_display_text!

      e
    end
  end
end
