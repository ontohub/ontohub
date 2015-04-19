require 'sidekiq/worker'

class ActionWorker < BaseWorker
  def perform(action_id, klass, method, *args)
    action = Action.find(action_id)
    action.register_start_of_action
    action.resource = klass.constantize.send(method, *args)
    action.save!
  end
end
