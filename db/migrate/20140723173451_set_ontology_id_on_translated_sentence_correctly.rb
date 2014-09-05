class SetOntologyIdOnTranslatedSentenceCorrectly < ActiveRecord::Migration
  def up
    TranslatedSentence.all.each do |sentence|
      sentence.ontology_id = sentence.sentence.read_attribute(:ontology_id)
      sentence.save!
    end
  end

  def down
    # There is no reversal for that,
    # the erroneous ontology_id has been replaced
  end
end
