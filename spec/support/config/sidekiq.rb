# https://github.com/mperham/sidekiq/wiki/Testing

require 'sidekiq/testing'

RSpec.configure do |config|
  config.before(:each) do
    # Clears out the jobs for tests using the fake testing
    Sidekiq::Worker.clear_all

    if example.metadata[:sidekiq] == :inline
      Sidekiq::Testing.inline!
    elsif example.metadata[:type] == :acceptance
      Sidekiq::Testing.inline!
    elsif example.metadata[:needs_hets]
      Sidekiq::Testing.inline!
    elsif example.metadata[:process_jobs_synchronously]
      Sidekiq::Testing.inline!
    else
      Sidekiq::Testing.fake!
    end
  end
end
