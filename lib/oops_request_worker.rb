class OopsRequestWorker < BaseWorker
  sidekiq_options retry: 3, queue: 'default'

  def perform(oops_request_id)
    OopsRequest.find(oops_request_id).run
  end
end
