class ProjectsController < InheritedResources::Base
  belongs_to :ontology
  before_filter :check_read_permissions

  def index
    @ontology = Ontology.find(params[:ontology_id])
    @projects = @ontology.projects
  end

  protected

  def check_read_permissions
    authorize! :show, parent.repository if parent.is_a? Ontology
  end
end
