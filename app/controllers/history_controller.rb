class HistoryController < InheritedResources::Base
  defaults resource_class: HistoryEntriesPage
  defaults singleton: true
  actions :show

  before_filter :check_read_permissions

  protected

  def resource
    @history_entries ||= HistoryEntriesPage.find(params)
  end

  def check_read_permissions
    authorize! :show, Repository.find_by_path!(params[:repository_id])
  end
end
