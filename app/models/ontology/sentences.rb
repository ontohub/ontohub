module Ontology::Sentences
  extend ActiveSupport::Concern

  included do
    has_many :sentences,
      autosave: false,
      extend:   Methods
    include GraphStructures::SqlHelper

    def translated_sentences
      split_translated_sentences.flatten
    end

    def split_translated_sentences
      translated = TranslatedSentence.where(audience_id: self)
      sentence_ids = translated.pluck(:sentence_id)
      imported = self.direct_imported_ontologies.reduce([[], []]) do |arr, ontology|
        other_split = ontology.split_translated_sentences
        other_translated = other_split.first
        other_translated.delete_if do |translated_sentence|
          sentence_ids.include?(translated_sentence.sentence_id)
        end
        other_sentences = other_split.last
        other_sentences.delete_if do |sentence|
          sentence_ids.include?(sentence.id)
        end
        other_translated.each { |ot| arr.first << ot }
        other_sentences.each { |os| arr.last << os }
        arr
      end
      [translated + imported.first, self.sentences + imported.last]
    end

    def incoming_imports_with_mappings
      # INNER JOINS always return an empty result set if the
      # ON clause does not match.
      Link.joins(:entity_mappings).where(target_id: self, kind: 'import')
    end

    def create_translated_sentences
      query, args = links_by_kind_query(self, 'import')
      imported_ontology_ids = pluck_select([query, *args], :id).reverse
      imported_ontology_ids.each { |o_id| Ontology.find(o_id).create_translated_sentences }
      import_links = incoming_imports_with_mappings
      if import_links.any?
        sentences.each do |sentence|
          import_links.each do |import_link|
            import_link.entity_mappings.each do |mapping|
              translate_sentence(sentence, mapping)
            end
          end
        end
      end
    end

    def translate_sentence(sentence, mapping)
      entity_ids = sentence.entities.pluck(:id)
      entity_intersection = entity_ids.include?(mapping.source_id)
      if entity_intersection
        translated_text = mapping.apply(sentence)
        audience = mapping.link.source
        TranslatedSentence.create(audience: audience,
                                  sentence: sentence,
                                  translated_text: translated_text,
                                  ontology: self)
      end
    end

    protected
    def translate_sentences_for(audience_ontology)
      link = Link.where(source_id: audience_ontology, target_id: self, kind: 'import').first
      mappings = link.entity_mappings
      if mappings.any?
        create_or_fetch_translations(audience_ontology, link, mappings)
      else
        default_translated_sentences
      end
    end

    # If there are no translations applicable, what do you do?
    def default_translated_sentences
      self.sentences
    end

    def create_or_fetch_translations(audience_ontology, link, mappings, overwrite: false)
      translations = TranslatedSentence.for(audience_ontology, sentences_from: self)
      if translations.any? && !overwrite
        translations
      else
        translations.delete_all
        create_translations(audience_ontology, link, mappings)
      end
    end

    def create_translations(audience_ontology, link, mappings)
      query, args = links_by_kind_query(self, 'import')
      imported_ontology_ids = pluck_select([query, *args], :id).reverse
      imported_ontology_ids.each { |o_id| Ontology.find(o_id).create_translated_sentences }
    end
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

    def translated_for(audience)

    end

  end
end
