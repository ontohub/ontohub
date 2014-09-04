class HetsInstance < ActiveRecord::Base
  attr_accessible :name, :uri

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
end
