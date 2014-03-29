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

    # Find import-links which describe the following mapping:
    # some ontology imports self.
    def incoming_imports_with_mappings
      # INNER JOINS always return an empty result set if the
      # ON clause does not match.
      Link.joins(:entity_mappings).where(source_id: self, kind: 'import')
    end

    def create_translated_sentences
      query, args = links_by_kind_query(self, 'import')
      imported_ontology_ids = pluck_select([query, *args], :ontology_id).reverse
      imported_ontology_ids.each { |o_id| Ontology.find(o_id).create_translated_sentences }
      import_links = incoming_imports_with_mappings
      if import_links.any?
        combined_sentences.each do |sentence|
          import_links.each do |import_link|
            import_link.entity_mappings.each do |mapping|
              translate_sentence(sentence, mapping)
            end
          end
        end
      end
    end

    def translate_sentence(sentence, mapping)
      applicable_sentence = TranslatedSentence.choose_applicable(sentence, mapping)
      if mapping.applicable?(applicable_sentence)
        translated_text = mapping.apply(applicable_sentence)
        audience = mapping.link.target
        translated_sentence = TranslatedSentence.where(
          entity_mapping_id: mapping,
          audience_id: audience,
          sentence_id: sentence,
          ontology_id: mapping.link.source).first_or_initialize
        translated_sentence.translated_text = translated_text
        translated_sentence.save
        translated_sentence
      end
    end

    protected
    def translate_sentences_for(audience_ontology)
      link = Link.where(source_id: audience_ontology, target_id: self, kind: 'import').first
      if link && link.entity_mappings.any?
        create_or_fetch_translations(audience_ontology, link, link.entity_mappings)
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
      sentence = find_or_initialize_by_name(hash['name'])

      sentence.imported   = hash['imported'] || false
      sentence.text       = hash['text'].to_s
      sentence.range      = hash['range']
      sentence.updated_at = timestamp

      sentence.save!

      execute_sql "DELETE FROM entities_sentences WHERE sentence_id=#{sentence.id}"
      execute_sql "INSERT INTO entities_sentences (sentence_id, entity_id, ontology_id)
                  SELECT #{sentence.id}, id, ontology_id FROM entities WHERE
                  ontology_id=#{@association.owner.id} AND text IN (?)",
                  hash['symbols']

      sentence.set_display_text!

      sentence
    end

  end
end
