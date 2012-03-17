module OntologyVersion::Async
  extend ActiveSupport::Concern
  
protected
  
  def do_or_set_failed(&block)
    raise ArgumentError.new('No block given.') unless block_given?

    begin
      yield
    rescue Exception => e
      update_state! :failed, e.message
      self.remove_raw_file!
      raise e
    end
  end

  def update_state!(state, error_message = nil)
    ontology.state = state.to_s
    ontology.save!

    self.state      = state.to_s
    self.last_error = error_message

    save!
  end
end
