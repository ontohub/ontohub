ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
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
Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
