module Ontology::Distributed
  extend ActiveSupport::Concern
  
  included do
    acts_as_tree
  end
  
  def distributed?
    is_a? DistributedOntology
  end

end
