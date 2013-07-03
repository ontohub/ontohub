module Ontology::Import
	extend ActiveSupport::Concern

  def import_xml(io, user)
    now = Time.now

    transaction do
      
      root             = nil
      ontology         = nil
      link             = nil
      ontologies_count = 0
      
      OntologyParser.parse io,
        root: Proc.new { |h|
          root = h
        },
        ontology: Proc.new { |h|
          ontologies_count += 1
          
          if distributed?
            # generate IRI for sub-ontology
            child_name = h['name']
            child_iri  = iri_for_child(child_name)
            
            # find or create sub-ontology by IRI
            ontology   = self.children.find_by_iri(child_iri)
            ontology ||= SingleOntology.create!({iri: child_iri, name: child_name, parent: self}, without_protection: true)
          else
            raise "more than one ontology found" if ontologies_count > 1
            ontology = self
          end

          if h['language']
            ontology.language = Language.where(:iri => "http://purl.net/dol/language/#{h['language']}")
              .first_or_create(user: user, name: h['language'])
          end
          if h['logic']
            ontology.logic = Logic.where(:iri => "http://purl.net/dol/logics/#{h['logic']}")
            .first_or_create(user: user, name: h['logic'])
          end

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
        },
        link: Proc.new { |h|
          self.links.update_or_create_from_hash(h, user, now)
        }
      save!
    end
  end

  def import_xml_from_file(path, user)
    import_xml File.open(path), user
  end

  def import_latest_version(user)
    return if versions.last.nil?
    return if versions.last.xml_file.blank?
    import_xml_from_file versions.last.xml_file.current_path, user
  end
end
