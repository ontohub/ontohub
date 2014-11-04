class DistributedOntology < Ontology
  def self.model_name
    Ontology.model_name
  end

  def to_partial_path
    'ontology'
  end

end
