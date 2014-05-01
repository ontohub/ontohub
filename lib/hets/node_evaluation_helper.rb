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
      # generate IRI for sub-ontology
      child_iri = parent_ontology.iri_for_child(internal_iri)

      # find or create sub-ontology by IRI
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
      version.code_reference = code_reference_for(ontology.name)

      hets_evaluator.versions << version

      ontology
    end

  end
end
