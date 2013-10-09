module PathHelpers
  extend ActiveSupport::Concern

  included do
    helper_method :fancy_repository_path
  end

  def fancy_repository_path(repository, params)
    params ||= {}
    action = params[:action] || :files
    if (params[:oid].nil? || repository.is_head?(params[:oid])) && action == :files
      repository_tree_path repository, path: params[:path]
    else
      repository_ref_path repository_id: repository, oid: params[:oid], action: action, path: params[:path]
    end
  end

end