 namespace :test do

  desc "Run all test suites and push coverage data to Coveralls"
  task :coveralls do
    # must be loaded before the test environment
    require 'coveralls'

    Rake::Task["spec"].invoke
    Rake::Task["test"].invoke

    Coveralls.push!
  end

end
