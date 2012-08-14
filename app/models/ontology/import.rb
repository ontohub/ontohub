module Ontology::Import
	extend ActiveSupport::Concern

  def import_xml(io)
    now = Time.now

    transaction do
      
      root             = nil
      ontology         = nil
      ontologies_count = 0
      
      OntologyParser.parse io,
        root: Proc.new { |h|
          root = h
        },
        ontology: Proc.new { |h|
          ontologies_count += 1
          
          if distributed?
            # generate IRI for sub-ontology
            name = h['name']
            name = "file://#{root['filename']}##{name}" unless name.include?('://')
            
            # find or create sub-ontology by IRI
            ontology   = self.children.find_by_iri name
            ontology ||= SingleOntology.create!({iri: name, parent: self}, without_protection: true)
          else
            raise "more than one ontology found" if ontologies_count > 1
            ontology = self
          end
          
          ontology.language = Language.find_or_create_by_name_and_iri h['logic'], 'http://purl.net/dol/language/' + h['logic']
          ontology.logic    = Logic.find_or_create_by_name_and_iri h['logic'], 'http://purl.net/dol/logics/' + h['logic']
          ontology.entities_count  = 0
          ontology.sentences_count = 0
        },
        ontology_end: Proc.new {
          # remove outdated sentences and entities
          conditions = ['updated_at < ?', now]
          ontology.entities.where(conditions).destroy_all
          ontology.sentences.where(conditions).delete_all
          ontology.save!
        },
        symbol:   Proc.new { |h|
          ontology.entities.update_or_create_from_hash(h, now)
          ontology.entities_count += 1
        },
        axiom: Proc.new { |h|
          ontology.sentences.update_or_create_from_hash(h, now)
          ontology.sentences_count += 1
        }
      
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
