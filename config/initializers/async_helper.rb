class ActiveRecord::Base

  # Creates a async_<methodname> method that
  # enqueues the corresponding method call.
  def self.async_method(*methods)
    methods.each do |method|
      define_method "async_#{method}" do |*args|
        async method, *args
      end
    end
  end

  def self.async(method, *args)
    async_in 'class', 1, method.to_s, *args
  end

  # Enqueues a method to run in the background
  def async(method, *args)
    # 1 second in the future should be after finishing the SQL transaction
    self.class.async_in 'record', 1, method.to_s, id.to_s, *args
  end

  # Enqueues a method to run in the future
  def self.async_in(type, at, *args)
    Sidekiq::Client.push \
      'queue'     => instance_variable_get('@queue') || 'default',
      'class'     => Worker,
      'retry'     => false,
      'args'      => [type, self.to_s, *args],
      'at'        => (at < 1_000_000_000 ? Time.now + at : at).to_f
  end

end
