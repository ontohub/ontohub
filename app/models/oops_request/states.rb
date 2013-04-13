# 
# states:
# * pending
# * processing
# * failed
# * done
# 
module OopsRequest::States
  extend ActiveSupport::Concern
  
  include StateUpdater
  
  included do
    @queue = 'oops'
    
    after_create :async_run, if: ->{ responses.empty? }
  end
  
  def async_run
    async :run
  end
  
  def run
    update_state! 'processing'
    
    do_or_set_failed do
      execute_and_save
      update_state! 'done'
    end
  end
  
end