module PathHelpers
  extend ActiveSupport::Concern

  included do
    helper_method :fancy_repository_path, :in_ref_path?
  end

  def in_ref_path?
    !params[:ref].nil?
  end

  def fancy_repository_path(repository, args)
    args ||= {}
    action = args[:action] || :show
    if !in_ref_path? && action == :show && !args[:exact_commit]
      repository_tree_path repository, path: args[:path]
    else
      repository_ref_path repository_id: repository, ref: args[:ref], action: action, path: args[:path]
    end
  end

end
