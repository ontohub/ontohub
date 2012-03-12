namespace :god do
  desc 'Start god'
  task :start do
    system 'cd ~/current && RAILS_ENV=production bundle exec god -c ~/current/config/god/app.rb'
  end
  
  desc 'Stop god'
  task :stop do
    system 'cd ~/current && RAILS_ENV=production bundle exec god terminate'
  end
  
  desc 'Restart god'
  task :restart => [:stop, :start] do
  end
end
