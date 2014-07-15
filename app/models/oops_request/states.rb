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
    async_method :run
    after_create :async_run, if: ->{ responses.empty? }
  end

  def run
    update_state! 'processing'

    do_or_set_failed do
      execute_and_save
      update_state! 'done'
    end
  end

end
