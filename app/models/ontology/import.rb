module Ontology::Import
	extend ActiveSupport::Concern

  def import_xml(io, code_io, user)
    now = Time.now

    transaction do
      code_doc = code_io ? Nokogiri::XML(code_io) : nil
      self.present     = true
      root             = nil
      ontology         = nil
      logic_callback   = nil
      link             = nil
      ontologies_count = 0
      versions = []

      OntologyParser.parse io,
        root: Proc.new { |h|
          root = h
        },
        ontology: Proc.new { |h|
          child_name = h['name']
          internal_iri = h['name'].start_with?('<') ? h['name'][1..-2] : h['name']

          if h['reference'] == 'true'
            ontology = Ontology.find_with_iri(internal_iri)
            if ontology.nil?
              ontology = SingleOntology.create!({name: child_name,
                                                 iri: ExternalRepository.determine_iri(internal_iri),
                                                 basepath: ExternalRepository.determine_path(internal_iri, :basepath),
                                                 file_extension: ExternalRepository.determine_path(internal_iri, :extension),
                                                 present: true,
                                                 repository_id: ExternalRepository.repository.id},
                                                 without_protection: true)
            end
            begin
              commit_oid = ExternalRepository.add_to_repository(
                internal_iri,
                "add reference ontology: #{internal_iri}", user)
              version = ontology.versions.build
              version.user = user
              version.do_not_parse!
              version.commit_oid = commit_oid
              version.state = 'done'
              versions << version
            rescue
              ontology.present = false
            end
          else
            ontologies_count += 1
            if distributed?
              # generate IRI for sub-ontology

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

              ontology.present = true
              version = ontology.versions.build
              version.user = user
              version.code_reference = code_reference_for(ontology.name, code_doc)

              versions << version
            else
              if ontologies_count > 1
                raise "more than one ontology found"
              else
                ontology = self
                ontology.present = true
              end
            end
          end
          ontology.name = ontology.generate_name(h['name'])
          if h['language']
            ontology.language = Language.where(:iri => "http://purl.net/dol/language/#{h['language']}")
              .first_or_create(user: user, name: h['language'])
          end
          if h['logic']
            ontology.logic = Logic.where(:iri => "http://purl.net/dol/logics/#{h['logic']}")
            .first_or_create(user: user, name: h['logic'])
          end

          altIri = ontology.alternative_iris.where(iri: internal_iri).
            first_or_create(ontology: ontology)

          Rails.logger.warn("found IRI: #{altIri.inspect}")

          logic_callback = ParsingCallback.determine_for(ontology)

          ontology.entities_count  = 0
          ontology.sentences_count = 0

          logic_callback.ontology(h, ontology)
        },
        ontology_end: Proc.new {
          # remove outdated sentences and entities
          conditions = ['updated_at < ?', now]
          ontology.entities.where(conditions).destroy_all
          ontology.sentences.where(conditions).delete_all
          ontology.save!

          logic_callback.ontology_end({}, ontology)
        },
        symbol: Proc.new { |h|
          if logic_callback.pre_symbol(h)
            entity = ontology.entities.update_or_create_from_hash(h, now)
            ontology.entities_count += 1

            logic_callback.symbol(h, entity)
          end
        },
        axiom: Proc.new { |h|
          if logic_callback.pre_axiom(h)
            sentence = ontology.sentences.update_or_create_from_hash(h, now)
            ontology.sentences_count += 1

            logic_callback.axiom(h, sentence)
          end
        },
        link: Proc.new { |h|
          if logic_callback.pre_link(h)
            link = self.links.update_or_create_from_hash(h, user, now)

            logic_callback.link(h, link)
          end
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
    import_version(versions.last, user)
  end

  def import_version(version, user)
    return if version.nil?
    import_xml_from_file version.xml_path,
      version.code_reference_path, user
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
