#require_relative '../data/20160310132620_move_loc_id_to_own_model_data.rb'
class MoveLocIdToOwnModel < MigrationWithData
  CLASSES = [Mapping,
             OntologyMember::Symbol,
             Ontology,
             ProofAttempt,
             ProverOutput,
             Theorem,
             Axiom].freeze
  TABLES = CLASSES.map(&:table_name).uniq.freeze

  def up
    File.open('migration.txt', 'a') do |f|
    begin
    #duplicate_locid_objects = []
    total = 0
    CLASSES.each do |klass|
      count = klass.count
      total += count
      f.puts("#{klass}.count = #{count}")
    end
    f.puts('')
    CLASSES.each do |klass|
      count = klass.count
      num_done = 0
      klass.find_each do |object|
        attrs = select_attributes(object, :locid)
        num_done += 1
        f.puts("#{num_done}/#{count} (#{(100*num_done.to_f/count).round(2)}%)\t - #{klass}##{object.id}\t#{attrs[:locid]}")
        begin
          locid = LocId.where(locid: attrs[:locid])
          if locid.any?
            #duplicate_locid_objects << {locid: attrs[:locid],
                                        #id: object.id,
                                        #class: normalized_class(klass)}
          else
            locid.first_or_create(specific_id: object.id,
                                  specific_type: normalized_class(klass).to_s)
          end
        rescue => e
          f.puts("ERROR #{e}")
        end
      end
      end
      end
    end

    TABLES.each { |table| remove_columns table, :locid }
    return

#    begin
#      run_data_migration(duplicate_locid_objects) if duplicate_locid_objects.any?
#    rescue => e
#      f.puts("ERROR #{e}")
#    end
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
    # MoveLocIdToOwnModelData.reanalyze_duplicates(duplicate_locid_objects)
  end
end
