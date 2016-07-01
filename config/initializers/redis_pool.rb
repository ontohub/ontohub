# This module is taken from
# http://ixti.net/development/ruby/2014/03/26/share-sidekiq-s-redis-pool-with-other-part-of-your-app.html
# and slightly adjusted to our needs
require 'redis/namespace'
module Ontohub
  class RedisConnection
    class Pool < ::ConnectionPool
      attr_accessor :namespace

      def initialize(options = {})
        super(options.delete :pool) { Redis.new(options) }
      end

      def with_namespace(ns)
        clone.tap { |o| o.namespace = ns }
      end

      def checkout(*args, &block)
        conn = super(*args, &block)

        if conn && namespace
          return ::Redis::Namespace.new(namespace, redis: conn)
        end

        conn
      end

      def wrap
        Wrapper.new(self)
      end

      class Wrapper < ::ConnectionPool::Wrapper
        def initialize(pool)
          @pool = pool
        end
      end
    end

    def pool
      @pool ||= Pool.new(config)
    end

    private

    def config
      {
        url: ::Settings.redis.url,
        timeout: 10.0,
        pool: {size: pool_size},
      }
    end

    def pool_size
      if ::Sidekiq.server?
        ::Sidekiq.options[:concurrency] + 2
      else
        5
      end
    end
  end

  def self.redis(*args, namespace: nil, &block)
    if block_given?
      RedisConnection.new.pool(*args).with_namespace(namespace, &block)
    elsif namespace
      RedisConnection.new.pool(*args).with_namespace(namespace).wrap
    else
      RedisConnection.new.pool(*args).wrap
    end
  end
end
