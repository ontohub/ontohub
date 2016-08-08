# This is an exceptional data migration. Only here, we don't use `up` or `down`
# but rather invoke `reanalyze_duplicates` to only parse the ontologies that
# contain LocId duplicates.
# It is invoked from the correspinding schema migration.
class MoveLocIdToOwnModelData < ActiveRecord::Migration
  # do nothing
  def self.up
  end

  # do nothing
  def self.down
  end

  def self.reanalyze_duplicates(duplicate_locid_objects)
    ontologies_to_parse = []
    duplicate_locid_objects.each do |duplicate|
      ontologies_to_parse << ontology_to_parse(duplicate)
    end

    ontologies_to_parse.uniq.each do |ontology|
      # The ontologies need to be parsed asynchronously because the HTTP server
      # does not respond during the migration.
      OntologySaver.new(ontology.repository).
        async_parse_version(ontology.current_version)
    end
  end

  def self.ontology_to_parse(duplicate)
    klass = duplicate[:class]
    if klass == Ontology || Ontology.subclasses.include?(klass)
      ontology = Ontology.find(duplicate[:id])
      if ontology.parent.is_a?(Ontology)
        ontology.parent
      else
        ontology
      end
    else
      klass.find(duplicate[:id]).ontology
    end
  end
end
