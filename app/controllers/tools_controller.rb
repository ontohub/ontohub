class ToolsController < InheritedResources::Base
  belongs_to :ontology
  def index
    @ontology = Ontology.find(params[:ontology_id])
    @projects = Project.where(ontology: @ontology)
  end
end
