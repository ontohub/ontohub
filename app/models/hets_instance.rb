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

  STATES = %w(free force-free busy)
  MUTEX_KEY = :choose_hets_instance
  FORCE_FREE_WAITING_PERIOD = 1.days

  attr_accessible :name, :uri, :state, :queue_size

  before_save :set_up_state, unless: Proc.new { |h| h.changed_attributes.key?("up") }
  before_save :set_state_updated_at
  after_create :start_update_clock

  validate :state, inclusion: {in: STATES}
  validate :queue_size, numericality: {greater_than_or_equal_to: 0}

  scope :active, -> do
    where(up: true).where('version >= ?', Hets.minimal_version_string)
  end
  scope :free, -> do
    where(state: 'free')
  end
  scope :force_free, -> do
    where(state: 'force-free')
  end
  scope :busy, -> do
    where(state: 'busy')
  end
  scope :load_balancing_order, -> do
    order('queue_size ASC').order('state_updated_at ASC')
  end

  def self.with_instance!
    instance = choose!
    begin
      result = yield(instance)
    rescue StandardError
      Semaphore.exclusively(MUTEX_KEY) { instance.finish_work! }
      raise
    end
    Semaphore.exclusively(MUTEX_KEY) { instance.finish_work! }
    result
  end

  def self.choose!(try_again: true)
    raise NoRegisteredHetsInstanceError.new unless any?
    instance = nil
    Semaphore.exclusively(MUTEX_KEY) do
      instance = active.free.first
      instance ||= increment_queue! { active.force_free.load_balancing_order.first }
      instance ||= increment_queue! { active.busy.load_balancing_order.first }
      instance.try(:set_busy!)
    end
    if instance
      instance
    elsif try_again
      find_each { |hets_instance| hets_instance.send(:set_up_state!) }
      choose!(try_again: false)
    else
      instance or raise NoSelectableHetsInstanceError.new
    end
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

  def finish_work!
    reload
    Sidekiq::Status.unschedule(@force_free_job_id)
    self.queue_size -= 1 if queue_size > 0
    if queue_size > 0
      set_busy!
    else
      set_free!
    end
    save!
  end

  def set_free!
    self.state = 'free'
    save!
  end

  def set_force_free!
    if reload.state == 'busy'
      self.state = 'force-free'
      save!
    end
  end

  def set_busy!
    self.state = 'busy'
    @force_free_job_id =
      HetsInstanceForceFreeWorker.perform_in(FORCE_FREE_WAITING_PERIOD, id)
    save!
  end

  protected

  def self.increment_queue!
    if instance = yield
      instance.queue_size += 1
      instance.save!
      instance
    end
  end

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

  def set_state_updated_at
    self.state_updated_at = Time.now if state_changed?
  end

  def start_update_clock
    HetsInstanceWorker.schedule_update(id)
  end
end
