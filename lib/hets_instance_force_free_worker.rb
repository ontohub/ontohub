class HetsInstanceForceFreeWorker < BaseWorker
  sidekiq_options queue: 'hets_load_balancing'

  def perform(hets_instance_id)
    Semaphore.exclusively(HetsInstance::MUTEX_KEY) do
      hets_instance = HetsInstance.find(hets_instance_id)
      hets_instance.set_force_free!
    end
  end
end
