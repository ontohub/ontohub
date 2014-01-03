after 'deploy:assets:symlink', 'rvm:create_bundle_wrapper'

namespace :rvm do
  task :create_bundle_wrapper, roles: :app do
    run "rvm wrapper #{rvm_ruby_string} bundle bundle"
  end  
end
