class FormalityLevelsController < InheritedResources::Base
  before_filter :check_read_permissions
  helper_method :repository, :ontology

  protected

  def check_read_permissions
    authorize! :show, repository
  end

  def repository
    @repository ||= Repository.find_by_path(params[:repository_id])
  end

  def ontology
    @ontology ||= Ontology.find(params[:ontology_id])
  end

  def collection
    ontology.formality_levels
  end

  protected

  def check_read_permissions
    authorize! :show, repository if repository
  end
end
