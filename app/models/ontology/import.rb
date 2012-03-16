module Ontology::Import
	extend ActiveSupport::Concern

  def import_xml(io)
    entities_count = 0
    axioms_count   = 0
    now            = Time.now

    transaction do
      OntologyParser.parse io,
        ontology: Proc.new { |h| 
          self.logic = Logic.find_or_create_by_name h['logic']
        },
        symbol:   Proc.new { |h|
          entities.update_or_create_from_hash(h, now)
          entities_count += 1
        },
        axiom:    Proc.new { |h|
          axioms.update_or_create_from_hash(h, now)
          axioms_count += 1
        }

      # remove outdated axioms and entities
      conditions = ['updated_at < ?', now]
      self.entities.where(conditions).destroy_all
      self.axioms.where(conditions).delete_all
      
      # update the counters
      self.entities_count = entities_count
      self.axioms_count   = axioms_count
      
      save!
    end
  end

  def import_xml_from_file(path)
    import_xml File.open path
  end

  def import_latest_version
    import_xml_from_file versions.last.xml_file.current_path
  end
end
