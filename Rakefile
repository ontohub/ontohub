#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'coveralls/rake/task'
Coveralls::RakeTask.new

require File.expand_path('../lib/rake/task.rb', __FILE__)
require File.expand_path('../config/application', __FILE__)

Ontohub::Application.load_tasks

# Prevent Rspec to print file list unless enforced by the environment.
if defined?(RSpec) && ENV['SPEC_VERBOSE'] != 'true'
  task(:spec).clear
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.verbose = false
  end
end

# Remove load_schema/load_structure in tests, as db:migrate:clean
# will take care of everything.
Rake::Task['db:test:clone'].prerequisites.delete('db:test:load_schema')
Rake::Task['db:test:clone'].prerequisites << 'db:test:purge'
Rake::Task['db:test:clone_structure'].prerequisites.delete('db:test:load_structure')
Rake::Task['db:test:clone_structure'].prerequisites << 'db:test:purge'

# Run all test suites per default
Rake::Task['default'].prerequisites.delete('spec')
Rake::Task['default'].prerequisites.delete('cucumber')
Rake::Task['default'].enhance([:'test:abort_if_elasticsearch_is_not_running'])
Rake::Task['default'].enhance([:'test:enable_coverage'])
Rake::Task['default'].enhance([:'test:freshen_fixtures'])
task :default => [:spec, :cucumber, 'coveralls:push']
