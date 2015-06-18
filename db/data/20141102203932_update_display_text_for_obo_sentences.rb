class UpdateDisplayTextForOboSentences < ActiveRecord::Migration
  def up
    obo_ontologies = Ontology.joins(:ontology_version).
      where(ontology_versions: {file_extension: '.obo'})
    obo_ontologies.each do |ontology|
      ontology.sentences.select(%i(id text)).find_each(&:set_display_text!)
    end
  end

  alias_method :down, :up
end
