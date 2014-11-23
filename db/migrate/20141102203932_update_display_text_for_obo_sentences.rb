class UpdateDisplayTextForOboSentences < ActiveRecord::Migration
  def up
    obo_ontologies = Ontology.joins(:ontology_version).
      where(ontology_versions: {file_extension: '.obo'})
    obo_ontologies.each do |ontology|
      ontology.sentences.find_each { |s| s.set_display_text! }
    end
  end

  alias_method :down, :up
end
