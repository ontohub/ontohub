class Ontology
  module Sentences
    extend ActiveSupport::Concern

    included do
      include SqlHelper

      def translated_sentences
        split_translated_sentences.flatten
      end

      def translated_axioms
        split_translated_sentences(:axioms).flatten
      end

      def split_translated_sentences(method = :sentences)
        translated = TranslatedSentence.where(audience_id: self)
        sentence_ids = translated.pluck(:sentence_id)
        imported =
          direct_imported_ontologies.reduce([[], []]) do |arr, ontology|
            other_split = ontology.split_translated_sentences(method)
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
        [translated + imported.first, send(method).original + imported.last]
      end

      # Find import-mappings which describe the following mapping:
      # some ontology imports self.
      def incoming_imports_with_mappings
        # INNER JOINS always return an empty result set if the
        # ON clause does not match.
        Mapping.joins(:symbol_mappings).where(source_id: self, kind: 'import')
      end

      def create_translated_sentences
        query, args = mappings_by_kind_query(self, 'import')
        imported_ontology_ids =
          pluck_select([query, *args], :ontology_id).reverse
        imported_ontology_ids.each do |o_id|
          Ontology.find(o_id).create_translated_sentences
        end
        import_mappings = incoming_imports_with_mappings
        if import_mappings.any?
          combined_sentences.each do |sentence|
            import_mappings.each do |import_mapping|
              import_mapping.symbol_mappings.each do |mapping|
                translate_sentence(sentence, mapping)
              end
            end
          end
        end
      end

      def translate_sentence(sentence, mapping)
        applicable_sentence =
          TranslatedSentence.choose_applicable(sentence, mapping)
        if mapping.applicable?(applicable_sentence)
          translated_text = mapping.apply(applicable_sentence)
          audience = mapping.mapping.target
          translated_sentence = TranslatedSentence.where(
            symbol_mapping_id: mapping,
            audience_id: audience,
            sentence_id: sentence,
            ontology_id: sentence.ontology).first_or_initialize
          translated_sentence.translated_text = translated_text
          translated_sentence.save
          translated_sentence
        end
      end

      protected
      def translate_sentences_for(audience_ontology)
        mapping = Mapping.where(source_id: audience_ontology,
                                target_id: self,
                                kind: 'import').first
        if mapping && mapping.symbol_mappings.any?
          create_or_fetch_translations(audience_ontology, mapping,
            mapping.symbol_mappings)
        else
          default_translated_sentences
        end
      end

      # If there are no translations applicable, what do you do?
      def default_translated_sentences
        sentences
      end

      def create_or_fetch_translations(audience_ontology, mapping, mappings,
        overwrite: false)
        translations =
          TranslatedSentence.for(audience_ontology, sentences_from: self)
        if translations.any? && !overwrite
          translations
        else
          translations.delete_all
          create_translations(audience_ontology, mapping, mappings)
        end
      end

      def create_translations(_audience_ontology, _mapping, _mappings)
        query, args = mappings_by_kind_query(self, 'import')
        imported_ontology_ids = pluck_select([query, *args], :id).reverse
        imported_ontology_ids.each do |o_id|
          Ontology.find(o_id).create_translated_sentences
        end
      end
    end

    module Methods

      def update_or_create_from_hash(hash, timestamp = Time.now)
        sentence = find_or_initialize_by_name(hash['name'])

        sentence.imported   = hash['imported'] || false
        sentence.text       = hash['text'].to_s
        sentence.range      = hash['range']
        sentence.updated_at = timestamp
        set_theorem_attributes(sentence, hash) if sentence.is_a?(Theorem)

        sep = '//'

        sentence.save!
        LocId.where(
                    locid: "#{sentence.ontology.locid}#{sep}#{sentence.name}",
                    assorted_object_id: sentence.id,
                    assorted_object_type: sentence.class,
                   ).first_or_create!
        execute_sql(
          "DELETE FROM sentences_symbols WHERE sentence_id=#{sentence.id}")
        execute_sql(
          "INSERT INTO sentences_symbols (sentence_id, symbol_id, ontology_id)
          SELECT #{sentence.id}, id, ontology_id FROM symbols WHERE
          ontology_id=#{@association.owner.id} AND text IN (?)",
          hash['symbols'])

        sentence.set_display_text!

        sentence
      end

      private

      def set_theorem_attributes(theorem, hash)
        theorem.provable = hash['status'] == 'open'
        if hash['status'] == 'proven'
          status_id = ProofStatus::DEFAULT_PROVEN_STATUS
          theorem.state = 'done'
        else
          status_id = ProofStatus::DEFAULT_OPEN_STATUS
          theorem.state = 'not_started_yet'
        end
        theorem.proof_status = ProofStatus.find(status_id)
      end

    end
  end
end
