class TasksController < InheritedResources::Base
  belongs_to :ontology
  before_filter :check_read_permissions

  def index
    @ontology = Ontology.find(params[:ontology_id])
    @projects = Project.where(ontology: @ontology)
  end

  protected

  def check_read_permissions
    authorize! :show, parent.repository
  end

end
