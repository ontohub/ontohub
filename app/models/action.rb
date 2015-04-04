class Action < ActiveRecord::Base
  belongs_to :resource, polymorphic: true

  attr_accessible :initial_eta, :resource

  def self.enclose!(initial_eta, klass, method, *args)
    action = create!(initial_eta: initial_eta)
    ActionWorker.perform_async(action.id, klass.to_s, method, *args)
    action
  end

  def eta(time = Time.now)
    diff = (created_at + initial_eta) - time
    [diff, 0].max
  end

  def status
    if resource.nil?
      'waiting'
    elsif resource.respond_to?(:state)
      resource.state
    elsif resource.respond_to?(:status)
      resource.status
    else
      raise NoMethodError, "resource does know neither state nor status."
    end
  end
end
