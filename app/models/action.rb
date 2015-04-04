class Action < ActiveRecord::Base
  belongs_to :resource, polymorphic: true

  attr_accessible :initial_eta, :resource

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
