# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../test/shared_helper", __FILE__)

include SharedHelper
use_simplecov

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require Rails.root.join('config', 'database_cleaner.rb')

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
  ontology_file("xml/#{name}")
end

def ontology_file(path)
  Rails.root + "test/fixtures/ontologies/" + path
end

def add_fixture_file(repository, relative_file)
  path = File.join(Rails.root, 'test', 'fixtures', 'ontologies', relative_file)
  version_for_file(repository, path)
end

def version_for_file(repository, path)
  dummy_user = FactoryGirl.create :user
  basename = File.basename(path)
  version = repository.save_file path, basename, "#{basename} added", dummy_user
end

# includes the convenience-method `define_ontology('name')`
include OntologyUnited::Convenience

def parse_this(user, ontology, xml_path, code_path)
  opts =
    if ontology.current_version
      version = ontology.current_version
      allow(version).to receive(:xml_path) { xml_path }
      allow(version).to receive(:code_reference_path) { code_path }
      {version: version}
    else
      {
        path: xml_path,
        code_path: code_path
      }
    end
  evaluator = Hets::Evaluator.new(user, ontology, opts)
  evaluator.import
end

RSpec.configure do |config|
  # ## Mock Framework
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  config.before(:each) do
    redis = WrappingRedis::RedisWrapper.new
    redis.del redis.keys if redis.keys.any?
  end

  config.after(:each) do
  end

  config.expose_current_running_example_as :example

  config.infer_spec_type_from_file_location!

  config.infer_base_class_for_anonymous_controllers = true

  config.include Devise::TestHelpers, type: :controller

  config.treat_symbols_as_metadata_keys_with_true_values = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end
