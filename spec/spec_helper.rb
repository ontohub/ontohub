# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../test/shared_helper", __FILE__)

include SharedHelper
use_simplecov

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require Rails.root.join('config', 'database_cleaner.rb')
require 'addressable/template'
require 'webmock/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

class ActionController::TestRequest

  attr_writer :query_string

  def query_string
    @query_string.to_s
  end

end

def fixture_file(path)
  fixture_path = Rails.root.join('test/fixtures/')
  fixture_path.join(path)
end

def ontology_file(path, ext=nil)
  portion =
    if ext
      "#{path}.#{ext}"
    elsif path.include?('.')
      path
    else
      "#{path}.#{path.to_s.split('/').first}"
    end
  fixture_file("ontologies/#{portion}")
end

def hets_out_file(name, ext='xml')
  ontology_file("hets-out/#{name}.#{ext}")
end

def hets_uri(portion = nil)
  hets_instance = HetsInstance.choose
  if hets_instance.nil?
    FactoryGirl.create(:local_hets_instance)
    hets_instance = HetsInstance.choose
  end
  specific = "#{portion}.*" if portion
  %r{#{hets_instance.uri}/dg/.*#{specific}}
end

def stub_hets_for(fixture_file, with: nil)
  stub_request(:get, 'http://localhost:8000/version').
    to_return(body: Hets.minimal_version_string)
  stub_request(:get, hets_uri(with)).
    to_return(body: fixture_file.read)
end

def setup_hets
  let(:hets_instance) { create(:local_hets_instance) }
  before do
    stub_request(:get, 'http://localhost:8000/version').
      to_return(body: Hets.minimal_version_string)
    hets_instance
  end
end

def add_fixture_file(repository, relative_file)
  path = ontology_file(relative_file)
  version_for_file(repository, path)
end

def version_for_file(repository, path)
  dummy_user = FactoryGirl.create :user
  basename = File.basename(path)
  version = repository.save_file path, basename, "#{basename} added", dummy_user
end

# includes the convenience-method `define_ontology('name')`
include OntologyUnited::Convenience

def parse_this(user, ontology, fixture_file)
  file = File.open(fixture_file)
  evaluator = Hets::Evaluator.new(user, ontology, io: file)
  evaluator.import
  file.close unless file.closed?
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
