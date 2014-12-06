class Ontology
  module OwlClasses
    extend ActiveSupport::Concern

    class Error < ::StandardError; end
    class WrongLogicError < Error; end

    def superclass_of?(superclass, subclass)
      check_logic_is_owl
      superclasses(subclass).include?(superclass)
    end

    def superclasses(cls)
      check_logic_is_owl
      result = []

      direct_superclasses(cls).each do |superclass|
        result << superclass
        result += superclasses(superclass)
      end

      result.uniq
    end

    def direct_superclasses(cls)
      check_logic_is_owl
      result = []
      sentences.where('text LIKE  ?', "Class: #{cls}%SubClassOf:%").
        each do |sentence|
          match = sentence.text.match(/SubClassOf: (?<superclass>\w+)\z/)
          result << match[:superclass] if match
        end

      result
    end

    def subclasses(cls)
      check_logic_is_owl
      result = []

      direct_subclasses(cls).each do |subclass|
        result << subclass
        result += subclasses(subclass)
      end

      result.uniq
    end

    def direct_subclasses(cls)
      check_logic_is_owl
      result = []
      sentences.where('text LIKE  ?', "Class: %SubClassOf: #{cls}").
        each do |sentence|
          match = sentence.text.match(/^Class: (?<subclass>\w+)/)
          result << match[:subclass] if match
        end

      result
    end

    protected

    def check_logic_is_owl
      raise WrongLogicError('Expected OWL') unless logic.name.start_with?('OWL')
    end
  end
end
