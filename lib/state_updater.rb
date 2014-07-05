require 'sidekiq/cli'

module StateUpdater
  extend ActiveSupport::Concern

  included do
    scope :state, ->(*states){
      where state: states.map(&:to_s)
    }
  end

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
        # Can really happen (SQL Exceptions, etc.)
        error  = "Nested exception on updating state of #{self.class} #{id}\n"
        error << "#{ee.class}: #{ee}\n  " << ee.backtrace.join("\n  ") << "\n"
        error << "#{e.class}: #{e}\n  "   <<  e.backtrace.join("\n  ")

        # Update attributes without any callbacks
        self.class.where(id: id).update_all \
          state:            'failed',
          state_updated_at: Time.now,
          last_error:       error

        # re-raise
        raise
      end
      raise
    end
  end

  def update_state!(state, error_message = nil)
    self.state            = state.to_s
    self.state_updated_at = Time.now
    self.last_error       = error_message
    save!
  end
end
