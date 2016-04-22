require_relative '../data/20160310132620_move_loc_id_to_own_model_data.rb'
class MoveLocIdToOwnModel < MigrationWithData
  CLASSES = [Mapping,
             OntologyMember::Symbol,
             Ontology,
             ProofAttempt,
             ProverOutput,
             Sentence]
  TABLES = CLASSES.map(&:table_name)

  def up
    duplicate_locid_objects = []
    CLASSES.each do |klass|
      klass.find_each do |object|
        attrs = select_attributes(object, :locid)
        begin
          locid = LocId.where(locid: attrs[:locid])
          if locid.any?
            duplicate_locid_objects << {locid: attrs[:locid],
                                        id: object.id,
                                        class: normalized_class(klass)}
          else
            locid.first_or_create(specific_id: object.id,
                                  specific_type: normalized_class(klass).to_s)
          end
        end
      end
    end

    TABLES.each { |table| remove_columns table, :locid }

    run_data_migration(duplicate_locid_objects) if duplicate_locid_objects.any?
  end

  def down
    TABLES.each { |table| add_column table, :locid }

    LocId.find_each do |object|
      attrs = select_attributes(object, :locid, :specific_id, :specific_type)
      specific = attrs[:specific_type].constantize.find(attrs[:specific_id])
      update_attributes!(specific, locid: attrs[:locid])
    end
  end

  def normalized_class(klass)
    # Sometimes the objects are "Ontology" and sometimes a subclass.
    if [DistributedOntology, SingleOntology].include?(klass)
      Ontology
    else
      klass
    end
  end

  def run_data_migration(duplicate_locid_objects)
    MoveLocIdToOwnModelData.reanalyze_duplicates(duplicate_locid_objects)
  end
end
