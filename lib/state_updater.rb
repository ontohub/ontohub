module StateUpdater
  
  protected
  
  def after_failed
    # override if necessary
  end
  
  def do_or_set_failed(&block)
    raise ArgumentError.new('No block given.') unless block_given?

    begin
      yield
    rescue Exception => e
      update_state! :failed, e.message
      after_failed
      raise e
    end
  end

  def update_state!(state, error_message = nil)

    self.state      = state.to_s
    self.last_error = error_message

    save!
  end
end
