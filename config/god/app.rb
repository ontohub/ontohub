require File.expand_path('../sidekiq_workers',  __FILE__)

SidekiqWorkers.configure do
  if ENV['RAILS_ENV']=='production'
    # one worker per core
    `nproc`.to_i.times.each do
      watch 'hets', 1
    end

    # one worker for the default queue
    watch 'default', 5

    # one worker for the sequential queue
    watch 'sequential', 1

    watch 'priority_push', 1
  else
    # one worker for all queues
    watch %w(hets default sequential priority_push), 1
  end
end
