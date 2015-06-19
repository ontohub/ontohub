require 'sidekiq/worker'

class HetsInstanceWorker < BaseWorker
  def self.schedule_update(hets_instance_id)
    update_span = Settings.hets.time_between_updates.hours
    perform_in(update_span, hets_instance_id)
  end

  def perform(hets_instance_id)
    HetsInstance.check_up_state!(hets_instance_id)
  ensure
    self.class.schedule_update(hets_instance_id)
  end
end
