module Repository::Ontologies
  extend ActiveSupport::Concern

  # list all failed versions, grouped by their errors
  def failed_ontology_versions
    ontologies
    .without_parent
    .map{|o| o.versions.last}
    .compact
    .select{|v| v.state!="done"}
    .group_by(&:state_message)
  end

  def primary_ontology(path)
    path ||= ''
    onto = ontologies.where(basepath: File.basepath(path)).first
    while !onto.nil? && !onto.parent.nil?
      onto = onto.parent
    end

    onto
  end
end
