class RepositoryDeletionWorker < BaseWorker
  sidekiq_options queue: 'default'

  def perform(id)
    Repository.destroying.find(id).destroy
  end
end
