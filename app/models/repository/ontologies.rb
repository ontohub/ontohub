module Repository::Ontologies
  extend ActiveSupport::Concern

  def primary_ontology(path)
    path ||= ''
    onto = ontologies.where(basepath: File.basepath(path)).first
    while !onto.nil? && !onto.parent.nil?
      onto = onto.parent
    end

    onto
  end
end
