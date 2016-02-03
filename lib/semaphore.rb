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
  SEMAPHORES_NAMESPACE = "#{Settings.redis.namespace}:#{self.to_s.downcase}"
  LOCK_ACTION_NAMESPACE = "#{SEMAPHORES_NAMESPACE}_lock_action"
  LOCK_ACTION_KEY = "lock_action"
  # We expect actions on a semaphore to perfom in milliseconds.
  # This value should be much more than enough.
  LOCK_ACTION_EXPIRATION = 10.seconds

  class << self
    def exclusively(lock_key, expiration: nil, &block)
      if sidekiq_inline?
        yield
      else
        perform_exclusively(lock_key, expiration: expiration, &block)
      end
    end

    def locked?(lock_key, expiration: nil)
      token = nil
      perform_action_on_semaphore do
        # Because of https://github.com/dv/redis-semaphore/issues/40, we need a
        # complex check if a lock is set. After redis-semaphore#40 is fixed,
        # this might be replaced by the use of my_redis_semaphore.locked?
        sema = retrieve_semaphore(lock_key, expiration: LOCK_ACTION_EXPIRATION)
        # lock(0) returns `"0"` if it was free and `false` if it was locked
        token = sema.lock(0)
        sema.unlock if token
      end
      !token
    end

    protected

    def perform_exclusively(lock_key, expiration: expiration)
      sema = retrieve_semaphore(lock_key, expiration: expiration)
      perform_action_on_semaphore { sema.lock }
      result = yield
      perform_action_on_semaphore { sema.unlock }
      result
    ensure
      sema.try(:unlock)
    end

    def perform_action_on_semaphore
      retrieve_semaphore_for_lock_action.lock do
        yield
      end
    end

    def retrieve_semaphore(lock_key, expiration: nil)
      Redis::Semaphore.new(lock_key,
                           expiration: expiration,
                           redis: redis(SEMAPHORES_NAMESPACE))
    end

    # ONLY use this for very fast actions that operate on a semaphore.
    def retrieve_semaphore_for_lock_action
      Redis::Semaphore.new(LOCK_ACTION_KEY,
                           expiration: LOCK_ACTION_EXPIRATION,
                           redis: redis(LOCK_ACTION_NAMESPACE))
    end

    def redis(sema_namespace = 'semaphore')
      sidekiq_redis = Sidekiq.redis { |connection| connection }
      full_namespace = "#{sidekiq_redis.namespace}:#{sema_namespace}"
      Redis::Namespace.new(full_namespace, redis: sidekiq_redis.redis)
    end

    def sidekiq_inline?
      defined?(Sidekiq::Testing) && Sidekiq::Testing.inline?
    end
  end
end
