class ProofStatus
  module CreationFromOntology
    extend ActiveSupport::Concern

    SOLVED_STATUS = 'SUC'

    module ClassMethods
      def statuses
        szs_ontology.subclasses('Problem_Status')
      end

      def refresh_statuses
        old_statuses = ProofStatus.all.map(&:identifier)
        new_statuses = statuses
        (old_statuses - new_statuses).each do |identifier|
          ProofStatus.find(identifier).destroy
        end

        new_statuses.each { |status| refresh(status) }
      end

      def refresh(status)
        proof_status = ProofStatus.find_or_initialize_by_identifier(status)
        proof_status.name = proof_status_name(status)
        proof_status.label = label(status)
        proof_status.description = description(status)
        proof_status.solved = solved?(status)
        proof_status.save!
      end

      def label(status)
        label_sentence = szs_ontology.sentences.
          where('text LIKE  ?', "Class: #{status}%hasLabel%").first

        return nil unless label_sentence

        match = label_sentence.text.match(/#hasLabel[^#]+#(?<label>\w+)/)
        match[:label]
      end

      def proof_status_name(status)
        # The name of the proof status is in the owl-label of the class.
        # In owl, the label is for a natural language label. A name fits well
        # in there.
        symbol_by_name(status).label
      end

      def description(status)
        # The description is in the owl-comment of the class.
        # This way, the ontology is smaller than when using custom relations.
        symbol_by_name(status).comment
      end

      def solved?(status)
        status == SOLVED_STATUS ||
        szs_ontology.superclass_of?(SOLVED_STATUS, status)
      end

      protected

      def szs_ontology
        @szs_ontology ||= Repository.find_by_path('meta').ontologies.where(
          basepath: 'proof_statuses', file_extension: '.owl').first
      end

      def symbol_by_name(status)
        @symbols_by_name ||= {}

        @symbols_by_name[status] ||= szs_ontology.symbols.find_by_name(status)
      end
    end
  end
end
