class DistributedOntology < Ontology
  def self.model_name
    Ontology.model_name
  end

  def to_partial_path
    'ontology'
  end
  
  def iri_for_child(child_name)
    child_name.include?("://") ? child_name : "#{iri}?#{child_name}"
  end
  
end
