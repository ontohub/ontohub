# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../spec/shared_helper", __FILE__)

include SharedHelper
use_simplecov

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require Rails.root.join('config', 'database_cleaner.rb')
require 'addressable/template'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)
elasticsearch_port = ENV['ELASTIC_TEST_PORT'].present? ? ENV['ELASTIC_TEST_PORT'] : '9250'
Elasticsearch::Model.client = Elasticsearch::Client.new host: "localhost:#{elasticsearch_port}"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

class ActionController::TestRequest

  attr_writer :query_string

  def query_string
    @query_string.to_s
  end

end

def controllers_locid_for(resource, *args, &block)
  request.env["action_controller.instance"].
    send(:locid_for, resource, *args, &block)
end

def fixture_file(path)
  fixture_path = Rails.root.join('spec/fixtures/')
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

def prove_out_file(name, ext='proof.json')
  fixture_file("ontologies/hets-out/prove/#{name}.#{ext}")
end

def hets_uri(command = 'dg', portion = nil, version = nil)
  hets_instance = HetsInstance.choose
  if hets_instance.nil?
    create(:local_hets_instance)
    hets_instance = HetsInstance.choose
  end
  specific = ''
  # %2F is percent-encoding for forward slash /
  specific << "ref%2F#{version}.*" if version
  specific << "#{portion}.*" if portion
  %r{#{hets_instance.uri}/#{command}/.*#{specific}}
end

def stub_hets_for(fixture_file, command: 'dg', with: nil, with_version: nil, method: :get)
  stub_request(:get, 'http://localhost:8000/version').
    to_return(body: Hets.minimal_version_string)
  stub_request(method, hets_uri(command, with, with_version)).
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
  dummy_user = create :user
  basename = File.basename(path)
  version = repository.save_file path, basename, "#{basename} added", dummy_user
end

# includes the convenience-method `define_ontology('name')`
include OntologyUnited::Convenience

def parse_this(user, ontology, fixture_file)
  file = File.open(fixture_file)
  evaluator = Hets::DG::Evaluator.new(user, ontology, io: file)
  evaluator.import
  file.close unless file.closed?
end

# Recording HTTP Requests
VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr'
  c.hook_into :webmock
  c.ignore_localhost = true
  c.ignore_hosts \
    '127.0.0.1',
    'localhost',
    'colore.googlecode.com',
    'trac.informatik.uni-bremen.de'
end

RSpec.configure do |config|
  # ## Mock Framework
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  config.tty ||= ENV["SPEC_OPTS"].include?('--color') if ENV["SPEC_OPTS"]

  config.before(:suite) do
    FactoryGirl.create :proof_statuses
  end

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

  config.mock_with :rspec do |mocks|
    mocks.yield_receiver_to_any_instance_implementation_blocks = false
  end
end
