# The Semaphore class allows to lock resources. The processes are blocked, i.e.
# not polling, when they wait for a lock to be opened.
# They are executed in order they arrive at the lock.
#
# It is based on Redis::Semaphore and can be extended to allow multiple
# processes to enter the critical path.
# Currently, only a mutex is implemented in this abstraction.
class Semaphore
  def self.exclusively(lock_key, &block)
    Redis::Semaphore.new(lock_key,
                         redis: redis,
                         expiration: 120).lock { yield }
  end

  protected

  def self.redis
    Sidekiq.redis { |connection| connection }.redis
  end
end
