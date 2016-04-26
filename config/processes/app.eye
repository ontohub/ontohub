require 'fileutils'
require File.expand_path('../../../lib/environment_light_with_hets.rb', __FILE__)
require File.expand_path('../eye_methods.rb', __FILE__)

Eye.config do
  logger "#{Rails.root}/log/eye.log"
end

def hets_queue_thread_count
  # One thread per configured hets instance, minus one for the sequential queue.
  [1, Settings.hets.instance_urls.size - 1].max
end

Eye.application :ontohub do
  working_dir Rails.root.to_s
  env 'RAILS_ENV' => Rails.env
  env 'PID_DIR' => Rails.root.join('tmp', 'pids').to_s

  # Create PID dir
  FileUtils.mkdir_p(env['PID_DIR'])

  group :sidekiq do
    # prioritize queues:
    # priority_push 5x as high as hets, which is 5x as high as hets-migration
    sidekiq_process self, :"sidekiq-hets",
                    ['priority_push,25', 'hets,5', 'hets-migration,1'],
                    hets_queue_thread_count

    # one multithreaded worker for the default queue and hets_load_balancing
    sidekiq_process self, :'sidekiq-default', ['default', 'hets_load_balancing'], 5

    # one worker for the sequential queue
    sidekiq_process self, :'sidekiq-sequential', 'sequential', 1
  end

  group :hets do
    Settings.hets.instance_urls.each do |url|
      if url.match(%r{\Ahttps?://(localhost|127.0.0.1|0.0.0.0|::1)})
        hets_process self, URI(url).port
      end
    end
  end
end
