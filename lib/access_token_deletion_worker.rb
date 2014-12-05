require 'sidekiq/worker'

# This worker deletes expired access tokens
class AccessTokenDeletionWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  def perform
    AccessToken.destroy_expired
  end
end
