module Hets
  class NodeEvaluator < BaseNodeEvaluator
    include NodeEvaluationHelper

    attr_accessor :current_element
    attr_accessor :internal_iri

    register :all, :end, to: :all_end
    register :root           , :start , to: :dgraph
    register :ontology       , :start , to: :ontology_start
    register :ontology       , :end   , to: :ontology_end
    register :import         , :start , to: :import
    register :symbol         , :end   , to: :symbol
    register :axiom          , :end   , to: :axiom
    register :imported_axiom , :end   , to: :imported_axiom
    register :link           , :end   , to: :link

    def dgraph(current_element)
      hets_evaluator.dgnode_count = current_element['dgnodes'].to_i
    end

    def all_end
      hets_evaluator.versions.compact.each do |version|
        version.save!
        version.ontology.update_version!(to: version)
      end
      hets_evaluator.ontologies.each(&:create_translated_sentences)
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

    def ontology_start(current_element)
      self.internal_iri = child_name = current_element['name']

      ontohub_iri = generate_ontology_iri(internal_iri, current_element)

      initiate_concurrency_handling(ontohub_iri)

      self.ontology = procure_ontology(current_element, internal_iri)

      ontology.name = ontology.generate_name(current_element['name'])

      assign_language(ontology, current_element)
      assign_logic(ontology, current_element)

      ontology.save!

      altIri = ontology.alternative_iris.where(iri: internal_iri).
        first_or_create(ontology: ontology)

      self.logic_callback = ParsingCallback.determine_for(ontology)

      logic_callback.ontology(current_element, ontology)
    end

    def ontology_end(*ignore_args)
      logic_callback.ontology_end({}, ontology)

      finish_concurrency_handling
    end

    def symbol(current_element)
      if logic_callback.pre_symbol(current_element)
        entity = ontology.entities.update_or_create_from_hash(current_element, hets_evaluator.now)
        ontology.entities_count += 1

        logic_callback.symbol(current_element, entity)
      end
    end

    def axiom(current_element)
      if logic_callback.pre_axiom(current_element)
        sentence = ontology.sentences.update_or_create_from_hash(current_element, hets_evaluator.now)
        ontology.sentences_count += 1

        logic_callback.axiom(current_element, sentence)
      end
    end

    def imported_axiom(current_element)
      if logic_callback.pre_axiom(current_element)
        current_element['imported'] = true
        sentence = ontology.sentences.update_or_create_from_hash(current_element, hets_evaluator.now)
        ontology.sentences_count += 1

        logic_callback.axiom(current_element, sentence)
      end
    end

    def link(current_element)
      if logic_callback.pre_link(current_element)
        alias_iris_for_links!(current_element)
        link = parent_ontology.links.update_or_create_from_hash(current_element, user, hets_evaluator.now)
        logic_callback.link(current_element, link)
      end
    end

    def import(current_element)
      location = current_element['location']
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
        hets_evaluator.versions << version
      rescue
        ontology.present = false
      end
    end

    def alias_iris_for_links!(current_element)
      aliases = hets_evaluator.ontology_aliases
      current_element['source_iri'] = aliases[current_element['source']]
      current_element['target_iri'] = aliases[current_element['target']]
    end

  end
end
