namespace :test do

  # We want to purge our database our own way, without deleting everything
  Rake::Task['db:test:purge'].overwrite do
    Rails.env = 'test'
    Rake::Task['db:redis:clean'].invoke
    Rake::Task['db:migrate:clean'].invoke
  end

  desc "Run all test suites and push coverage data to Coveralls"
  task :coveralls do
    # must be loaded before the test environment
    require 'coveralls'

    Rake::Task["spec"].invoke
    Rake::Task["test"].invoke

    Coveralls.push!
  end

end
