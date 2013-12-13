ENV["RAILS_ENV"] = "test"
# Sunspot checks this constant to determine the environment
RAILS_ENV = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...

  def fixture_file(name)
    Rails.root + 'test/fixtures/ontologies/xml/' + name
  end

  def open_fixture(name)
    File.open(fixture_file(name))
  end

  def solr_setup
    unless $sunspot
      $sunspot = Sunspot::Rails::Server.new

      pid = fork do
        STDERR.reopen('/dev/null')
        STDOUT.reopen('/dev/null')
        $sunspot.run
      end
      # shut down the Solr server
      at_exit { Process.kill('TERM', pid) }
      # wait for solr to start
      sleep 5
    end

    Sunspot.session = $original_sunspot_session
  end

  setup do
    # clean git repositories
    FileUtils.rmtree Ontohub::Application.config.git_root
    FileUtils.rmtree Ontohub::Application.config.git_working_copies_root
    FileUtils.rmtree Repository::Symlink::PATH
    solr_setup
  end

  teardown do
    Entity.remove_all_from_index!
  end

end

# for devise
class ActionController::TestCase
  include Devise::TestHelpers
end

# for strip_attributes
require "strip_attributes/matchers"
class Test::Unit::TestCase
  extend StripAttributes::Matchers
end

# For Sidekiq
require 'sidekiq/testing'
Sidekiq::Testing.fake!

# Recording HTTP Requests
VCR.configure do |c|  
  c.cassette_library_dir = 'test/fixtures/vcr'
  c.hook_into :webmock
  c.ignore_localhost = true
  c.ignore_hosts \
    '127.0.0.1',
    'localhost',
    'colore.googlecode.com',
    'trac.informatik.uni-bremen.de'
end

# disable sunspot during tests
$original_sunspot_session = Sunspot.session
Sunspot.session = Sunspot::Rails::StubSessionProxy.new($original_sunspot_session)

