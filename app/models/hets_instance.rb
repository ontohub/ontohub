class HetsInstance < ActiveRecord::Base
  class Error < ::StandardError; end
  class NoRegisteredHetsInstanceError < Error
    DEFAULT_MSG = 'There is no registered HetsInstance for this application'

    def initialize(msg = DEFAULT_MSG)
      super
    end
  end

  class NoSelectableHetsInstanceError < Error
    DEFAULT_MSG = <<-MSG
There is no HetsInstance which is reachable and
has a minimal Hets version of #{Hets.minimal_version_string}
    MSG

    def initialize(msg = DEFAULT_MSG)
      super
    end
  end

  attr_accessible :name, :uri

  before_save :set_up_state
  after_create :start_update_clock

  scope :active_instances, -> do
    where(up: true).where('version >= ?', Hets.minimal_version_string)
  end

  def self.choose!
    raise NoRegisteredHetsInstanceError.new unless any?
    instance = active_instances.first
    instance or raise NoSelectableHetsInstanceError.new
  end

  def self.check_up_state!(hets_instance_id)
    find(hets_instance_id).send(:set_up_state!)
  end

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

  def start_update_clock
    HetsInstanceWorker.schedule_update(id)
  end
end
