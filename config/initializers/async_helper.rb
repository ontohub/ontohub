class ActiveRecord::Base
  
  # Enqueues a method to run in the background
  def async(method, *args)
    # 1 second in the future should be after finishing the SQL transaction
    async_in method, 1, *args
  end

  # Enqueues a method to run in the future
  def async_in(method, at, *args)
    Sidekiq::Client.push \
      'queue'     => self.class.instance_variable_get('@queue') || 'default',
      'class'     => Worker,
      'args'      => [self.class.to_s, id.to_s, method.to_s, *args],
      'at'        => (at < 1_000_000_000 ? Time.now + at : at).to_f
  end

end
