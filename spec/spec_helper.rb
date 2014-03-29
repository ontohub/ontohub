# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../test/shared_helper", __FILE__)

include SharedHelper
use_simplecov

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'database_cleaner'

require 'sidekiq/testing'
# Setting the default for sidekiq testing
# some specs rely on this being the default.
# However unit-tests use a different default (fake!)
Sidekiq::Testing.inline!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

class ActionController::TestRequest

  attr_writer :query_string

  def query_string
    @query_string.to_s
  end

end

def fixture_file(name)
  Rails.root + 'test/fixtures/ontologies/xml/' + name
end

RSpec.configure do |config|
  # ## Mock Framework
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.infer_base_class_for_anonymous_controllers = true

  config.include Devise::TestHelpers, type: :controller

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end
