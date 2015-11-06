require 'fileutils'
require File.expand_path('../../../lib/environment_light_with_hets.rb', __FILE__)
require File.expand_path('../eye_methods.rb', __FILE__)

Eye.config do
  logger "#{Rails.root}/log/eye.log"
end

Eye.application :ontohub do
  working_dir Rails.root.to_s
  env 'RAILS_ENV' => Rails.env
  env 'PID_DIR' => Rails.root.join('tmp', 'pids').to_s

  # Create PID dir
  FileUtils.mkdir_p(env['PID_DIR'])

  group :sidekiq do
    # one worker per configured hets instance
    Settings.hets.instance_urls.each_with_index do |_url, index|
      sidekiq_process self, :"sidekiq-hets-#{index}", 'hets', 1
    end

    # one worker for hets load balancing
    sidekiq_process self, :'sidekiq-hets-load-balancing', 'hets_load_balancing', 1

    # one worker for the default queue
    sidekiq_process self, :'sidekiq-default', 'default', 5

    # one worker for the sequential queue
    sidekiq_process self, :'sidekiq-sequential', 'sequential', 1

    sidekiq_process self, :'sidekiq-priority_push', 'priority_push', 1
  end

  group :hets do
    Settings.hets.instance_urls.each do |url|
      if url.match(%r{\Ahttps?://(localhost|127.0.0.1|0.0.0.0|::1)})
        hets_process self, URI(url).port
      end
    end
  end
end
