# Worker for Sidekiq
class RepositoryUpdateWorker < Worker

  def perform(repo_path, oldrev, newrev, refname, key_id)
    repo_path =~ /(\d+)\/?\z/
    repo_id = $1.to_i
    Repository.where(id: repo_id).first!
      .suspended_save_ontologies \
        start_oid: newrev,
        stop_oid:  oldrev,
        walk_order: Rugged::SORT_REVERSE
  end

end
