# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../spec/shared_helper", __FILE__)

include SharedHelper
use_simplecov if ENV['COVERAGE']

require File.expand_path("../../config/environment", __FILE__)
require File.expand_path("../hets_helper", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require Rails.root.join('config', 'database_cleaner.rb')
require 'addressable/template'
require 'webmock'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

class ActionController::TestRequest

  attr_writer :query_string

  def query_string
    @query_string.to_s
  end

end

require Rails.root.join('spec', 'support', 'common_helper_methods.rb')
require Rails.root.join('spec', 'support', 'documentation_progress_formatter.rb')

def stub_cp_keys
  allow(AuthorizedKeysManager).to receive(:copy_authorized_keys_to_git_home)
end

def current_full_description
  RSpec.configuration.current_full_description
end

def current_description
  RSpec.configuration.current_description
end

def current_file_path
  prefix = 'spec/'
  full_path = RSpec.configuration.current_file_path
  full_path.match(/#{prefix}(?<path>.*)\.rb$/)[:path]
end

# Generate a generic cassette name for any example or context.
def generate_cassette_name
  "specs/#{current_file_path}/#{current_full_description}"
end

RSpec.configure do |config|
  config.add_setting :current_full_description
  config.add_setting :current_description
  config.add_setting :current_file_path
  # ## Mock Framework
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  config.tty ||= ENV["SPEC_OPTS"].include?('--color') if ENV["SPEC_OPTS"]

  config.before(:suite) do
    FactoryGirl.create :proof_statuses
  end

  config.before(:each) do |example|
    redis = WrappingRedis::RedisWrapper.new
    redis.del redis.keys if redis.keys.any?
    config.current_full_description =
      example.metadata[:example_group][:full_description]
    config.current_description = example.description
    config.current_file_path = example.file_path
  end

  config.after(:each) do
  end

  config.expose_current_running_example_as :example

  config.infer_spec_type_from_file_location!

  config.infer_base_class_for_anonymous_controllers = true

  config.include Devise::TestHelpers, type: :controller

  # The following option is already set in the database_cleaner.rb:
  # config.treat_symbols_as_metadata_keys_with_true_values = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.mock_with :rspec do |mocks|
    mocks.yield_receiver_to_any_instance_implementation_blocks = false
  end
end
