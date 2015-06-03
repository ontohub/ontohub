class DiffsController < InheritedResources::Base
  defaults resource_class: Diff
  defaults singleton: true
  actions :show

  before_filter :check_read_permissions

  def show
    @message = repository.commit_message(oid)
    resource.compute
    @changed_files = resource.changed_files
  end

  protected

  def resource
    @history_entries ||= Diff.new(params)
  end

  def repository
    @repository ||= Repository.find_by_path!(params[:repository_id])
  end

  def commit_id
    @commit_id ||= repository.commit_id(params[:ref])
  end

  def oid
    @oid ||= commit_id[:oid] unless commit_id.nil?
  end

  def check_read_permissions
    authorize! :show, repository
  end
end
