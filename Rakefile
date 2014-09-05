#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

class Rake::Task
  # methods found on http://blog.jayfields.com/2008/02/rake-task-overwriting.html
  def overwrite(&block)
    @actions.clear
    prerequisites.clear
    enhance(&block)
  end
  def abandon
    prerequisites.clear
    @actions.clear
  end
end

require File.expand_path('../config/application', __FILE__)

Ontohub::Application.load_tasks


# Remove load_schema/load_structure in tests, as db:migrate:clean
# will take care of everything.
Rake::Task['db:test:clone'].prerequisites.delete('db:test:load_schema')
Rake::Task['db:test:clone'].prerequisites << 'db:test:purge'
Rake::Task['db:test:clone_structure'].prerequisites.delete('db:test:load_structure')
Rake::Task['db:test:clone_structure'].prerequisites << 'db:test:purge'

# Run all test suites per default
task :default => [:spec, :test]
