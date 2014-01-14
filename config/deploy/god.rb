# https://makandracards.com/makandra/1431-resque-+-god-+-capistrano
namespace :god do
  def god_is_running
    !capture("#{god_command} status >/dev/null 2>/dev/null || echo 'not running'").start_with?('not running')
  end

  def god_command
    "cd #{current_path}; bundle exec god"
  end

  desc "Stop god"
  task :stop do
    if god_is_running
      run "#{god_command} terminate"
    end
  end

  desc "Test if god is running"
  task :status do
    puts god_is_running ? "God is running" : "God is NOT running"
  end
end

after "deploy:update", "god:stop"
