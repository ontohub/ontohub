module Ontology::Oops
  extend ActiveSupport::Concern
  
  OOPS_FORMATS = %w(OWL RDF)
  
  def oops_supported?
    is_a?(SingleOntology) && logic && OOPS_FORMATS.include?(logic.name)
  end

end
