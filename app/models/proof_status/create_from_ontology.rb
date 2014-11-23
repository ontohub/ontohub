module ProofStatus::CreateFromOntology
  extend ActiveSupport::Concern

  module ClassMethods
    def statuses
      subclasses('Problem_Status')
    end

    def refresh_statuses
      old_statuses = ProofStatus.all.map(&:identifier)
      new_statuses = statuses
      (old_statuses - new_statuses).each { |s| s.destroy }

      new_statuses.each { |status| refresh(status) }
    end

    def refresh(status)
      proof_status = ProofStatus.find_or_initialize_by_identifier(status)
      proof_status.name = proof_status_name(status)
      proof_status.label = label(status)
      proof_status.description = description(status)
      proof_status.solved = solved?(status)
      proof_status.save
    end

    def label(status)
      label_sentence = szs_ontology.sentences.
        where('text LIKE  ?', "Class: #{status}%hasLabel%").first

      if label_sentence
        m = label_sentence.text.match(/#hasLabel[^#]+#(?<label>\w+)/)
        m[:label]
      end
    end

    def proof_status_name(status)
      szs_ontology.entities.find_by_name(status).label
    end

    def description(status)
      szs_ontology.entities.find_by_name(status).comment
    end

    def solved?(status)
      status == 'SOL' || superclass_of?('SOL', status)
    end

    protected

    def superclass_of?(superclass, subclass)
      superclasses(subclass).include?(superclass)
    end

    def superclasses(cls)
      result = []

      direct_superclasses(cls).each do |superclass|
        result << superclass
        result += superclasses(superclass)
      end

      result.uniq
    end

    def direct_superclasses(cls)
      result = []
      szs_ontology.sentences.
        where('text LIKE  ?', "Class: #{cls}%SubClassOf:%").
        each do |sentence|
          m = sentence.text.match(/SubClassOf: (?<superclass>\w+)\z/)
          result << m[:superclass] if m
        end

      result
    end

    def subclasses(cls)
      result = []

      direct_subclasses(cls).each do |subclass|
        result << subclass
        result += subclasses(subclass)
      end

      result.uniq
    end

    def direct_subclasses(cls)
      result = []
      szs_ontology.sentences.
        where('text LIKE  ?', "Class: %SubClassOf: #{cls}").
        each do |sentence|
          m = sentence.text.match(/^Class: (?<subclass>\w+)/)
          result << m[:subclass] if m
        end

      result
    end

    def szs_ontology
      Repository.find_by_path('meta').ontologies.where(
        basepath: 'proof_statuses', file_extension: '.owl').first
    end
  end
end
