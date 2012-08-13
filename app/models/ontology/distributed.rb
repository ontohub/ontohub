module Ontology::Distributed
  extend ActiveSupport::Concern

  def distributed?
    is_a? DistributedOntology
  end

  def parents
    Ontology.where "id IN (SELECT distributed_ontology_id FROM members WHERE ontology_id = ? )", id
  end
  
  def children
    Ontology.where "id IN (SELECT ontology_id FROM members WHERE distributed_ontology_id = ? )", id
  end

end
