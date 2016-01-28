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
  def self.exclusively(lock_key, expiration: nil)
    if defined?(Sidekiq::Testing) && Sidekiq::Testing.inline?
      yield
    else
      Redis::Semaphore.new(lock_key,
                           redis: redis,
                           expiration: expiration).lock { yield }
    end
  end

  protected

  def self.redis
    Sidekiq.redis { |connection| connection }.redis
  end
end
