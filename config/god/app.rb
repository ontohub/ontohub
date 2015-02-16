require File.expand_path('../../../lib/environment_light', __FILE__)
require File.expand_path('../sidekiq_workers',  __FILE__)
require File.expand_path('../hets_workers',  __FILE__)

AppConfig::load

# High load workers (except hets) are: sequential and priority_push.
HIGH_LOAD_WORKERS_COUNT = 2
DEFAULT_WORKERS_COUNT = 4

God.pid_file_directory = File.join(AppConfig.root, 'tmp', 'pids')

# Gets the number of hets processes to use. The value of the global Option
# Settings.hets.workers (if available, otherwise 4) gets used as an upper
# limit when the result gets calculated.
# @return [Integer] the number of additional hets workers
def hets_workers_count
  min_workers = 1
  max_workers = [`nproc`.to_i - HIGH_LOAD_WORKERS_COUNT, min_workers].max
  hets = Object.const_defined?('Settings') ? Settings.hets : nil
  default = (hets && hets.workers) ? hets.workers : DEFAULT_WORKERS_COUNT
  [default, max_workers].min
end

SidekiqWorkers.configure do
  if AppConfig.env == 'production'
    # one worker per core
    hets_workers_count.times.each do
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

HetsWorkers.configure do
  watch
end
