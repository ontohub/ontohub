class TasksController < InheritedResources::Base
  belongs_to :ontology
  def index
    @ontology = Ontology.find(params[:ontology_id])
    @tasks = @ontology.tasks
  end
end
