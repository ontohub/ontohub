class UpdateDisplayTextForOboSentences < ActiveRecord::Migration
  def up
    obo_ontologies = Ontology.joins(:ontology_version).
      where(ontology_versions: {file_extension: '.obo'})
    obo_ontologies.each do |ontology|
      ontology.sentences.find_each do |sentence|
        sentence.set_display_text!
      end
    end
  end

  def down
    obo_ontologies = Ontology.joins(:ontology_version).
      where(ontology_versions: {file_extension: '.obo'})
    obo_ontologies.each do |ontology|
      ontology.sentences.find_each do |sentence|
        sentence.set_display_text!
      end
    end
  end
end
