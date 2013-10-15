require 'sidekiq/worker'

# Worker for Sidekiq
class Worker
  include Sidekiq::Worker

  def perform(clazz, id, method, *args)
    clazz.constantize.find(id).send method, *args
  end

  # This method definition is required by sidekiq
  def self.get_sidekiq_options
    {
      'backtrace' => true
    }
  end
  
end
