# Worker for Sidekiq
class RepositoryUpdateWorker < Worker
  sidekiq_options queue: 'hets'

  # This worker does not play a direct role
  # in concurrency balancing, because this
  # worker only creates other Jobs down
  # the line. It cannot experience the
  # ConcurrencyBalancer::AlreadyProcessingError.
  def perform(repo_path, oldrev, newrev, refname, key_id)
    repo_path =~ /(\d+)\/?\z/
    repo_id = $1.to_i
    Repository.where(id: repo_id).first!
      .suspended_save_ontologies \
        start_oid: newrev,
        stop_oid:  oldrev,
        walk_order: :reverse
  end

end
