class RepositoryConversionWorker < BaseWorker
  sidekiq_options retry: false, queue: 'default'

  # method can be "clone" or "pull"
  # remote_type can be nil (which is for git) or "svn"
  def perform(repository_id)
    Repository.find(repository_id).convert_to_local!
  end
end
