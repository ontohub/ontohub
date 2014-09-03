module Hets
  class NodeEvaluator < BaseNodeEvaluator
    include NodeEvaluationHelper

    attr_accessor :current_element
    attr_accessor :internal_iri

    register :all, :end, to: :all_end
    register :root, :start, to: :dgraph
    register :ontology, :start, to: :ontology_start
    register :ontology, :end, to: :ontology_end
    register :import, :start, to: :import
    register :symbol, :end, to: :symbol
    register :axiom, :end, to: :axiom
    register :imported_axiom, :end, to: :imported_axiom
    register :link, :end, to: :link

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

      ontology.save!

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
        version.basepath = ontology.basepath
        version.file_extension = ontology.file_extension
        hets_evaluator.versions << version
      rescue
        ontology.present = false
      end
    end

  end
end
