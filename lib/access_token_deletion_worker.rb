class AccessTokenDeletionWorker < BaseWorker
  sidekiq_options queue: 'default'

  def perform
    AccessToken.destroy_expired
  end
end
