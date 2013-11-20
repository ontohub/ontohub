class ProjectsController < InheritedResources::Base
  belongs_to :ontology
  def index
    @ontology = Ontology.find(params[:ontology_id])
    @project = @ontology.project
  end
end
