require 'sidekiq/worker'

# This worker creates remote_pull jobs
# to update imported repositories.
class SidetiqWorker

  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely(5) }

  def perform
    Repository.outdated.find_each{|r| r.async_remote :pull }
  end

end
