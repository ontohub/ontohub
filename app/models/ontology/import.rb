module Ontology::Import
	extend ActiveSupport::Concern

  def import_xml(io, code_io, user)
    now = Time.now

    transaction do
      code_doc = code_io ? Nokogiri::XML(code_io) : nil
      
      root             = nil
      ontology         = nil
      link             = nil
      ontologies_count = 0
      versions = []
      
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
            if ontology.nil?

              ontology = SingleOntology.create!({iri: child_iri,
                  name: child_name,
                  basepath: self.basepath,
                  file_extension: self.file_extension,
                  repository_id: repository_id},
                without_protection: true)
              self.children << ontology
            end
	    
            version = ontology.versions.build
            version.user = user
            version.code_reference = code_reference_for(ontology.name, code_doc)

            versions << version
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
      versions.each { |version| version.save! }

    end
  end

  def import_xml_from_file(path, code_path, user)
    code_io = code_path ? File.open(code_path) : nil
    import_xml File.open(path), code_io, user
  end

  def import_latest_version(user)
    latest_version = versions.last
    return if latest_version.nil?
    import_xml_from_file latest_version.xml_path,
      latest_version.code_reference_path, user
  end

  def code_reference_for(ontology_name, code_doc)
    return if code_doc.nil?
    elements = code_doc.xpath("//*[contains(@name, '##{ontology_name}')]")
    code_range = elements.first.try(:attr, "range")
    code_reference_from_range(code_range)
  end

  def code_reference_from_range(range)
    return if range.nil?
    match = range.match( %r{
      (?<begin_line>\d+)\.
      (?<begin_column>\d+)
      -
      (?<end_line>\d+)\.
      (?<end_column>\d+)}x)
    if match
      reference = CodeReference.new(begin_line: match[:begin_line].to_i,
        begin_column: match[:begin_column].to_i,
        end_line: match[:end_line].to_i,
        end_column: match[:end_column].to_i)
    end
  end

end
