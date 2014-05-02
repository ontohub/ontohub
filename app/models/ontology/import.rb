module Ontology::Import
	extend ActiveSupport::Concern

  def import_xml(io, code_io, user)
    now = Time.now

    transaction do
      code_doc         = code_io ? Nokogiri::XML(code_io) : nil
      concurrency      = ConcurrencyBalancer.new
      self.present     = true
      root             = nil
      ontology         = nil
      ontologies         = []
      logic_callback   = nil
      link             = nil
      ontologies_count = 0
      versions         = []
      dgnode_count     = 0
      dgnode_stack      = []
      next_dgnode_stack_id = ->() { dgnode_stack.length }
      dgnode_stack_id = ->() { next_dgnode_stack_id[] - 1 }
      internal_iri = nil
      ontology_aliases = {}

      OntologyParser.parse io,
        root: Proc.new { |h|
          root = h
          dgnode_count = root['dgnodes'].to_i
        },
        import: Proc.new { |h|
          location = h['location']
          source_iri = location ? location : internal_iri
          begin
            commit_oid = ExternalRepository.add_to_repository(
              internal_iri,
              "add reference ontology: #{internal_iri} from #{source_iri}", user,
              location: source_iri)
            version = ontology.versions.build
            version.user = user
            version.do_not_parse!
            version.commit_oid = commit_oid
            version.state = 'done'
            versions << version
          rescue
            ontology.present = false
          end
        },
        ontology: Proc.new { |h|
          child_name = h['name']
          internal_iri = h['name'].start_with?('<') ? h['name'][1..-2] : h['name']
          dgnode_stack_id ||= 0
          ontohub_iri = nil

          if h['reference'] == 'true'
            ontology = Ontology.find_with_iri(internal_iri)
            if ontology.nil?
              ontohub_iri = ExternalRepository.determine_iri(internal_iri)
            else
              ontohub_iri = ontology.iri
            end
          else
            if distributed?
              ontohub_iri = iri_for_child(internal_iri)
            else
              # we use 0 here, because the first time around, we
              # have ontologies_count 0 which is increased by one
              # after obtaining the lock. We need to preempt
              # this message, because otherwise we would
              # fail here with a lock issue instead of the
              # 'more than one ontology' issue.
              if ontologies_count > 0
                raise "more than one ontology found"
              else
                ontohub_iri = self.iri
              end
            end
          end

          concurrency.mark_as_processing_or_complain(ontohub_iri, unlock_this_iri: dgnode_stack[dgnode_stack_id[]])
          dgnode_stack << ontohub_iri

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
            ontology_aliases[h['name']] = ontology.iri
          else
            ontologies_count += 1
            if distributed?
              self.logic = Logic.where(
                  iri: "http://purl.net/dol/logics/#{Logic::DEFAULT_DISTRIBUTED_ONTOLOGY_LOGIC}")
                .first_or_create(user: user, name: Logic::DEFAULT_DISTRIBUTED_ONTOLOGY_LOGIC)

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

          ontology.entities.destroy_all
          ontology.all_sentences.destroy_all
          ontology.entities_count  = 0
          ontology.sentences_count = 0
          ontology.save!

          logic_callback.ontology(h, ontology)
        },
        ontology_end: Proc.new {
          ontologies << ontology

          logic_callback.ontology_end({}, ontology)

          concurrency.mark_as_finished_processing(dgnode_stack.last) if next_dgnode_stack_id[] == dgnode_count
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
        imported_axiom: Proc.new { |h|
          if logic_callback.pre_axiom(h)
            h['imported'] = true
            sentence = ontology.sentences.update_or_create_from_hash(h, now)
            ontology.sentences_count += 1

            logic_callback.axiom(h, sentence)
          end
        },
        link: Proc.new { |h|
          if logic_callback.pre_link(h)
            h['source_iri'] = ontology_aliases[h['source']]
            h['target_iri'] = ontology_aliases[h['target']]
            link = self.links.update_or_create_from_hash(h, user, now)

            logic_callback.link(h, link)
          end
        }
      save!
      versions.each(&:save!)
      ontologies.each(&:create_translated_sentences)

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
