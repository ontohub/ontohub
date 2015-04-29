class SetOntologyIdOnTranslatedSentenceCorrectly < MigrationWithData
  def up
    TranslatedSentence.find_each do |translated_sentence|
      ts_attrs = select_attributes(translated_sentence, :sentence_id)

      sentence = Sentence.find(ts_attrs[:sentence_id])
      sen_attrs = select_attributes(sentence, :ontology_id)

      update_attributes!(translated_sentence,
                         ontology_id: sen_attrs[:ontology_id])
    end
  end

  def down
    # There is no reversal for that,
    # the erroneous ontology_id has been replaced
  end
end
