module Ontology::Import
	extend ActiveSupport::Concern

  def import_xml(io)
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
            name = h['name']
            name = "file://#{root['filename']}##{name}" unless name.include?('://')
            
            # find or create sub-ontology by IRI
            ontology   = self.children.find_by_iri name
            ontology ||= SingleOntology.create!({iri: name, parent: self}, without_protection: true)
          else
            raise "more than one ontology found" if ontologies_count > 1
            ontology = self
          end

          if h['language']
            ontology.language = Language.find_or_create_by_name_and_iri h['language'], 'http://purl.net/dol/language/' + h['language']
          end
          if h['logic']
            ontology.logic = Logic.find_or_create_by_name_and_iri h['logic'], 'http://purl.net/dol/logics/' + h['logic']
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
=begin
            name = h['name'] # maybe nil, in this case, we need to generate a name
            source = h['source']
            target = h['target']
            name = "file://#{root['filename']}##{name}" unless name.include?('://')
            source = "file://#{root['filename']}##{source}" unless source.include?('://')
            target = "file://#{root['filename']}##{target}" unless target.include?('://')
            source_onto  = Ontology.find_by_iri source
            target_onto  = Ontology.find_by_iri target
            linktype = h['type']
            raise "link type missing" if linktype.nil?
            kind = if linktype.include? "Free" then "free"
                   elsif linktype.include? "Cofree" then "cofree"
                   elsif linktype.include? "Hiding" then "hiding"
                   elsif linktype.include? "Alignment" then "alignment"
                   elsif linktype.include? "Minimization" then "minimization"
                   else "import_or_viewif" end
            theorem = linktype.include? "Thm"
            proven = linktype.include? "Proven" 
            local = linktype.include? "Local"
            inclusion = linktype.include? "Inc"
            gmorphism = h['morphism']
            raise "gmorphism missing" if gmorphism.nil?
            gmorphism = 'http://purl.net/dol/translations/' + gmorphism unless gmorphism.include?('://')
            logic_mapping = LogicMapping.find_by_iri gmorphism
            link = Link.create!({iri: name, ontology: self, source: source_onto, target: target_onto,
                                 kind: kind, theorem: theorem, proven: proven, local: local,
                                 inclusion: inclusion, logic_mapping: logic_mapping }, without_protection: true)
=end
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
