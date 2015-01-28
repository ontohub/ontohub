class RepositoryDeletionWorker < BaseWorker
  sidekiq_options queue: 'default'

  def perform(id)
    Repository.unscoped.find(id).destroy
  end
end
