module Hets
  module DG
    class NodeEvaluator < ConcurrentEvaluator
      LOCID_UNIQUE_ERROR = 'index_loc_ids_on_locid'.freeze
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
      register :theorem, :end, to: :theorem
      register :mapping, :end, to: :mapping

      def dgraph(current_element)
        importer.dgnode_count = current_element['dgnodes'].to_i
      end

      def all_end
        importer.versions.compact.each do |version|
          version.save!
          version.ontology.update_version!(to: version)
        end
        importer.ontologies.each(&:create_translated_sentences)
        update_ontologies_per_logic_count!(importer.ontologies)
        importer.ontologies.each do |ontology|
          ontology.__elasticsearch__.index_document
          ontology.__elasticsearch__.update_document
        end
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

        ontology.current_version.state = 'done' if ontology.parent
        ontology.save!

        ontology.sentences.original.find_each(&:set_display_text!)

        finish_concurrency_handling
      end

      def symbol(current_element)
        if logic_callback.pre_symbol(current_element)
          symbol = ontology.symbols.update_or_create_from_hash(
            current_element, importer.now)
          ontology.symbols_count += 1

          logic_callback.symbol(current_element, symbol)
        end
      rescue ActiveRecord::RecordNotUnique => e
        if e.message.include?(LOCID_UNIQUE_ERROR)
          raise Hets::SyntaxError,
            I18n.t('ontology.parsing.errors.duplicate_name_many',
                   name: current_element['name'],
                   range: current_element['range'],
                   class: 'symbol',
                   type1: 'axiom',
                   type2: 'theorem')
        else
          raise e
        end
      end

      def axiom(current_element)
        if logic_callback.pre_axiom(current_element)
          axiom = ontology.axioms.update_or_create_from_hash(
            current_element, importer.now)
          ontology.axioms_count += 1
          ontology.sentences_count += 1

          logic_callback.axiom(current_element, axiom)
        end
      rescue ActiveRecord::RecordNotUnique => e
        if e.message.include?(LOCID_UNIQUE_ERROR)
          raise Hets::SyntaxError,
            I18n.t('ontology.parsing.errors.duplicate_name_many',
                   name: current_element['name'],
                   range: current_element['range'],
                   class: 'axiom',
                   type1: 'symbol',
                   type2: 'theorem')
        else
          raise e
        end
      end

      def imported_axiom(current_element)
        if logic_callback.pre_axiom(current_element)
          current_element['imported'] = true
          axiom = ontology.axioms.update_or_create_from_hash(
            current_element, importer.now)
          ontology.axioms_count += 1
          ontology.sentences_count += 1

          logic_callback.axiom(current_element, axiom)
        end
      rescue ActiveRecord::RecordNotUnique => e
        if e.message.include?(LOCID_UNIQUE_ERROR)
          raise Hets::SyntaxError,
            I18n.t('ontology.parsing.errors.duplicate_name_many',
                   name: current_element['name'],
                   range: current_element['range'],
                   class: 'axiom',
                   type1: 'symbol',
                   type2: 'theorem')
        else
          raise e
        end
      end

      def theorem(current_element)
        if logic_callback.pre_theorem(current_element)
          theorem = ontology.theorems.update_or_create_from_hash(
            current_element, importer.now)
          ontology.theorems_count += 1
          ontology.sentences_count += 1

          logic_callback.theorem(current_element, theorem)
        end
      rescue ActiveRecord::RecordNotUnique => e
        if e.message.include?(LOCID_UNIQUE_ERROR)
          raise Hets::SyntaxError,
                I18n.t('ontology.parsing.errors.duplicate_name_many',
                       name: current_element['name'],
                       range: current_element['range'],
                       class: 'theorem',
                       type1: 'axiom',
                       type2: 'symbol')
        else
          raise e
        end
      end

      def mapping(current_element)
        if logic_callback.pre_mapping(current_element)
          alias_iris_for_mappings!(current_element)
          mapping = parent_ontology.mappings.update_or_create_from_hash(
            current_element, user, importer.now)
          logic_callback.mapping(current_element, mapping)
        end
      rescue ActiveRecord::RecordNotUnique => e
        if e.message.include?(LOCID_UNIQUE_ERROR)
          raise Hets::SyntaxError,
            I18n.t('ontology.parsing.errors.duplicate_name_one',
                   name: current_element['name'],
                   range: current_element['range'],
                   class: Mapping.to_s,
                   type_with_article: 'a child ontology')
        else
          raise e
        end
      end

      def import(current_element)
        location = current_element['location']
        source_iri = location ? location : internal_iri
        begin
          commit_oid = ExternalRepository.add_to_repository(
            internal_iri,
            "add reference #{Settings.OMS}: #{internal_iri} from #{source_iri}",
            user, location: source_iri)
          version = ontology.versions.build
          version.user = user
          version.do_not_parse!
          version.commit_oid = commit_oid
          version.state = 'done'
          version.basepath = ontology.basepath
          version.file_extension = ontology.file_extension
          importer.versions << version
        rescue
          ontology.present = false
        end
      end
    end
  end
end
