# Worker for Sidekiq
class RepositoryUpdateWorker < Worker

  def perform(repo_path, oldrev, newrev, refname, key_id)
    Repository.where(path: repo_path).first!
      .suspended_save_ontologies \
        start_oid: newrev,
        stop_oid:  oldrev
  end

end
