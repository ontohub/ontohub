class UpdateDisplayNameForObo < ActiveRecord::Migration
  def up
    obo_ontologies = Ontology.joins(:ontology_version).
      where(ontology_versions: {file_extension: '.obo'})
    obo_ontologies.each do |ontology|
      ontology.entities.find_each do |entity|
        entity.set_obo_display_name_if_applicable
        entity.save!
      end
      begin
        TarjanTree.for(ontology)
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.warn <<-MSG
Could not create entity tree for:
  #{ontology.name} (#{ontology.id}) caused #{e}
        MSG
      end
    end
  end

  def down
    obo_ontologies = Ontology.joins(:ontology_version).
      where(ontology_versions: {file_extension: '.obo'})
    obo_ontologies.each do |ontology|
      ontology.entities.find_each do |entity|
        entity.set_display_name_and_iri
        entity.save!
      end
      begin
        TarjanTree.for(ontology)
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.warn <<-MSG
Could not create entity tree for:
  #{ontology.name} (#{ontology.id}) caused #{e}
        MSG
      end
    end
  end
end
