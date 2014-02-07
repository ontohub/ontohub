require 'sidekiq/cli'

module StateUpdater
  extend ActiveSupport::Concern
  
  included do
    scope :state, ->(*states){
      where state: states.map(&:to_s)
    }
  end

  protected
  
  def after_failed
    # override if necessary
  end
  
  def do_or_set_failed(&block)
    raise ArgumentError.new('No block given.') unless block_given?

    begin
      yield
    rescue Exception => e
      begin
        if Sidekiq::Shutdown === e
          # Sidekiq requeues the current job automatically
          update_state! :pending
        else
          update_state! :failed, e.message
          after_failed
        end
      rescue Exception => ee
        # Can really happen
        Rails.logger.fatal "Unable to update state of #{self.class} #{id}"
        raise
      end
      raise e
    end
  end

  def update_state!(state, error_message = nil)
    self.state            = state.to_s
    self.state_updated_at = Time.now
    self.last_error       = error_message
    save!
  end
end
