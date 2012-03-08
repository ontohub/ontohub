module Ontology::Import
	extend ActiveSupport::Concern

  module ClassMethods
    def import_from_xml(io)
      @logic_name = nil
      @entities   = []
      @axioms     = []

      OntologyParser.parse io,
        ontology: Proc.new { |h| @logic_name = h['logic'] },
        symbol:   Proc.new { |h| @entities << h },
        axiom:    Proc.new { |h| @axioms << h }

      p @logic_name, @entities, @axioms

      o = Ontology.new

      o.logic = Logic.find_or_create_by_name(@logic_name)

      o.entities.update_or_create_from_hash @entities
      o.axioms.update_or_create_from_hash @axioms

      o.save!
    end
  end
end
