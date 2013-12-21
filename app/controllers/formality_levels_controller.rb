class FormalityLevelsController < InheritedResources::Base
  before_filter :check_read_permissions
  helper_method :repository, :ontology

  def check_read_permissions
    authorize! :show, repository
  end

  protected

  def repository
    @repository ||= Repository.find_by_path(params[:repository_id])
  end

  def ontology
    @ontology ||= Ontology.find(params[:ontology_id])
  end

  def collection
    ontology.formality_levels
  end
end
