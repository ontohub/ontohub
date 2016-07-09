# The Semaphore class allows to lock resources. The processes are blocked, i.e.
# not polling, when they wait for a lock to be opened.
# They are executed in order they arrive at the lock.
#
# It is based on Redis::Semaphore and can be extended to allow multiple
# processes to enter the critical path.
# Currently, only a mutex is implemented in this abstraction.
#
# Expiration is given in seconds. Can be nil. If set, the Semaphore will unlock
# after `expiration` seconds.
#
# It takes a block containing the critical path.
class Semaphore
  SEMAPHORES_NAMESPACE =
    "#{Settings.redis.namespace}:#{self.to_s.downcase}".freeze

  delegate :locked?, to: :@sema

  def initialize(lock_key, expiration: nil)
    @sema = self.class.
      send(:retrieve_semaphore, lock_key, expiration: expiration)
  end

  def lock
    return if self.class.send(:sidekiq_inline?)
    @sema.lock
  end

  def unlock
    return if self.class.send(:sidekiq_inline?)
    @sema.unlock
  end

  class << self
    def exclusively(lock_key, expiration: nil, &block)
      if sidekiq_inline?
        yield
      else
        perform_exclusively(lock_key, expiration: expiration, &block)
      end
    end

    def locked?(lock_key)
      retrieve_semaphore(lock_key).locked?
    end

    protected

    def perform_exclusively(lock_key, expiration: nil)
      sema = retrieve_semaphore(lock_key, expiration: expiration)
      sema.lock
      result = yield
      sema.unlock
      result
    ensure
      sema.try(:unlock)
    end

    def retrieve_semaphore(lock_key, expiration: nil)
      Redis::Semaphore.new(lock_key,
                           expiration: expiration,
                           redis: redis(SEMAPHORES_NAMESPACE))
    end

    def redis(sema_namespace)
      Ontohub.redis(namespace: sema_namespace)
    end

    def sidekiq_inline?
      defined?(Sidekiq::Testing) && Sidekiq::Testing.inline?
    end
  end
end
