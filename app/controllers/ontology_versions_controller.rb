# 
# Displays versions of a ontology
# 
class OntologyVersionsController < InheritedResources::Base
  defaults :collection_name => :versions
  actions :index, :show
  belongs_to :ontology

  def show
    mime = 'text/plain'
    mime = 'application/rdf+xml' if resource.ontology.logic.name == 'OWL'
    send_file resource.raw_file.current_path, type: mime
  end
end
