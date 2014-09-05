module Hets
  module NodeEvaluationHelper

    def clean_ontology(ontology)
      ontology.entities.destroy_all
      ontology.all_sentences.destroy_all
      ontology.entities_count  = 0
      ontology.sentences_count = 0
      ontology.save!
    end

    def assign_language(ontology, current_element)
      if current_element['language']
        iri = "http://purl.net/dol/language/#{current_element['language']}"
        ontology.language = Language.where(iri: iri)
          .first_or_create(user: user, name: current_element['language'])
      end
    end

    def assign_logic(ontology, current_element)
      if current_element['logic']
        iri = "http://purl.net/dol/logics/#{current_element['logic']}"
        ontology.logic = Logic.where(iri: iri)
          .first_or_create(user: user, name: current_element['logic'])
      end
    end

    def assign_distributed_ontology_logic(ontology)
      iri = "http://purl.net/dol/logics/#{Logic::DEFAULT_DISTRIBUTED_ONTOLOGY_LOGIC}"
      name = Logic::DEFAULT_DISTRIBUTED_ONTOLOGY_LOGIC
      ontology.logic = Logic.where(iri: iri)
        .first_or_create(user: user, name: name)
    end

    def procure_child_ontology(internal_iri)
      # generate IRI for child-ontology
      child_iri = parent_ontology.iri_for_child(internal_iri)

      # find or create child-ontology by IRI
      ontology = parent_ontology.children.find_by_iri(child_iri)
      if ontology.nil?
        options = {
          iri: child_iri,
          name: internal_iri,
          basepath: parent_ontology.basepath,
          file_extension: parent_ontology.file_extension,
          repository_id: parent_ontology.repository_id,
          present: true,
        }
        ontology = SingleOntology.create!(options, without_protection: true)
        parent_ontology.children << ontology
      end

      version = ontology.versions.build
      version.user = user
      version.basepath = ontology.basepath
      version.parent = parent_version
      version.commit_oid = parent_version.try(:commit_oid)
      version.file_extension = ontology.file_extension
      # This version will not exist if the parsing fails
      version.state = 'done'
      version.do_not_parse!

      hets_evaluator.versions << version

      ontology
    end

    def parent_version
      hets_evaluator.version if parent_ontology
    end

    def alias_iris_for_links!(current_element)
      aliases = hets_evaluator.ontology_aliases
      current_element['source_iri'] = aliases[current_element['source']]
      current_element['target_iri'] = aliases[current_element['target']]
    end

    def generate_ontology_iri(internal_iri, current_element)
      if current_element['reference'] == 'true'
        ontology = Ontology.find_with_iri(internal_iri)
        if ontology.nil?
          ontohub_iri = ExternalRepository.determine_iri(internal_iri)
        else
          ontohub_iri = ontology.iri
        end
      else
        if parent_ontology.distributed?
          ontohub_iri = parent_ontology.iri_for_child(internal_iri)
        else
          # we use 0 here, because the first time around, we
          # have ontologies_count 0 which is increased by one
          # after obtaining the lock. We need to preempt
          # this message, because otherwise we would
          # fail here with a lock issue instead of the
          # 'more than one ontology' issue.
          if hets_evaluator.ontologies_count > 0
            raise "more than one ontology found"
          else
            ontohub_iri = parent_ontology.iri
          end
        end
      end
    end

    def procure_ontology(element, iri)
      if element['reference'] == 'true'
        ontology = Ontology.find_with_iri(iri)
        if ontology.nil?
          ontology = ExternalRepository.create_ontology(iri)
        end
        hets_evaluator.ontology_aliases[element['name']] = ontology.iri
      else
        hets_evaluator.ontologies_count += 1
        if parent_ontology.distributed?
          assign_distributed_ontology_logic(parent_ontology)

          ontology = procure_child_ontology(iri)
        else
          ontology = parent_ontology
          ontology.present = true
        end
      end
      clean_ontology(ontology)
      ontology
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
end
