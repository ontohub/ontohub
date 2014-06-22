class HistoryController < InheritedResources::Base
  defaults resource_class: HistoryEntries
  defaults singleton: true
  actions :show

  before_filter :check_read_permissions

  helper_method :repository, :ref, :oid, :path, :ontology

  protected

  def resource
    @history_entries ||= HistoryEntries.find(params)
  end

  def repository
    @repository ||= Repository.find_by_path!(params[:repository_id])
  end

  def ontology
    @ontology ||= repository.primary_ontology(path)
  end

  def ref
    params[:ref] || 'master'
  end

  def check_read_permissions
    authorize! :show, repository
  end

  def commit_id
    @commit_id ||= repository.commit_id(params[:ref])
  end

  def oid
    @oid ||= commit_id[:oid] unless commit_id.nil?
  end

  def path
    params[:path]
  end
end
