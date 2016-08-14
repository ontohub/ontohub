class RepositoryPullingWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options retry: false, queue: 'default'

  recurrence do
    hourly.minute_of_hour(0, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55)
  end

  def perform
    Repository.outdated.find_each { |r| r.call_remote :pull }
  end
end
