#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Ontohub::Application.load_tasks

# Run all test suites per default
task :default => [:spec, :test]

# Required by Coveralls to push a merged result for all test suites
require 'coveralls/rake/task'
Coveralls::RakeTask.new
task :test_with_coveralls => [:default, 'coveralls:push'] do
  ENV['USE_COVERALLS'] = 'true'
end
