class UpdateDisplayNameForObo < ActiveRecord::Migration
  def up
    obo_ontologies = Ontology.joins(:ontology_version).
      where(ontology_versions: {file_extension: '.obo'})
    obo_ontologies.each do |ontology|
      ontology.symbols.find_each do |symbol|
        symbol.set_obo_display_name_if_applicable
        symbol.save!
      end
      begin
        TarjanTree.for(ontology)
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.warn <<-MSG
Could not create symbol tree for:
  #{ontology.name} (#{ontology.id}) caused #{e}
        MSG
      end
    end
  end

  def down
    obo_ontologies = Ontology.joins(:ontology_version).
      where(ontology_versions: {file_extension: '.obo'})
    obo_ontologies.each do |ontology|
      ontology.symbols.find_each do |symbol|
        symbol.set_display_name_and_iri
        symbol.save!
      end
      begin
        TarjanTree.for(ontology)
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.warn <<-MSG
Could not create symbol tree for:
  #{ontology.name} (#{ontology.id}) caused #{e}
        MSG
      end
    end
  end
end
