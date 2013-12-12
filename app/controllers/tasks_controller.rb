class TasksController < InheritedResources::Base
  belongs_to :ontology
  before_filter :check_read_permissions

  def index
    @ontology = Ontology.find(params[:ontology_id])
    @tasks = @ontology.tasks
  end

  protected

  def check_read_permissions
    authorize! :show, parent.repository
  end

end
