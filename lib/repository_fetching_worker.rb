class RepositoryFetchingWorker < BaseWorker
  sidekiq_options retry: false, queue: 'default'

  # method can be "clone" or "pull"
  # remote_type can be nil (which is for git) or "svn"
  def perform(repository_id, method, remote_type)
    Repository.find(repository_id).fetch(method, remote_type)
  end
end
