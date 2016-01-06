class RepositoryPullingWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options retry: false, queue: 'default'

  recurrence { minutely(5) }

  def perform
    Repository.outdated.find_each { |r| r.call_remote :pull }
  end
end
