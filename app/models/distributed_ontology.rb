class DistributedOntology < Ontology

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  document_type 'distributed_ontology'
  index_name 'distrubuted_ontologies'

  def self.model_name
    Ontology.model_name
  end

  def to_partial_path
    'ontology'
  end

end
