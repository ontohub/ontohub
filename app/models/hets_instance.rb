class HetsInstance < ActiveRecord::Base
  attr_accessible :name, :uri

  before_save :set_up_state

  # will result in 0.99 for <v0.99, something or other>
  def general_version
    version.split(', ').first[1..-1] if version
  end

  # will result in 1409043198 for <v0.99, 1409043198>
  def specific_version
    version.split(', ').last if version
  end

  def up?
    up
  end

  def to_s
    "#{name}(#{uri})"
  end

  protected
  def check_up_state
    Hets::VersionCaller.new(self).call
  end

  def set_up_state
    version = check_up_state
    self.up = !! version
    self.version = version if up
  end

  def set_up_state!
    set_up_state
    save!
  end
end
