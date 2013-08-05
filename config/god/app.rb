require File.expand_path('../resque_workers',  __FILE__)

ResqueWorkers.configure do
  if ENV['RAILS_ENV']=='production'
    # one dedicated worker for oops
    watch 'oops'
    
    # two workers for all jobs
    watch '*', 2
  else
    # one worker for all jobs
    watch '*'
  end
end
