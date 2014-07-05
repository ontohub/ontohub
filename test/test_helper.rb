ENV["RAILS_ENV"] = "test"

require File.expand_path("../../test/shared_helper", __FILE__)

include SharedHelper
use_simplecov

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

  setup do
    # clean git repositories
    FileUtils.rmtree Ontohub::Application.config.data_root
    FileUtils.rmtree Repository::Symlink::PATH
    stub_ontology_file_extensions
  end

  teardown do
    unstub_ontology_file_extensions
  end

end

# for devise
class ActionController::TestCase
  include Devise::TestHelpers
  setup { stub_ontology_file_extensions }
  teardown { unstub_ontology_file_extensions }
end

# for strip_attributes
require "strip_attributes/matchers"
class Test::Unit::TestCase
  extend StripAttributes::Matchers
end


def stub_ontology_file_extensions
  Ontology.stubs(:file_extensions_distributed).returns(
    %w[casl dol hascasl het].map!{ |ext| ".#{ext}" })
  Ontology.stubs(:file_extensions_single).returns(
    %w[owl obo hs exp maude elf hol isa thy prf omdoc hpf clf clif xml fcstd rdf xmi qvt tptp gen_trm baf].
    map!{ |ext| ".#{ext}" })
end

def unstub_ontology_file_extensions
  Ontology.unstub(:file_extensions_distributed)
  Ontology.unstub(:file_extensions_single)
end

# For Sidekiq
require 'sidekiq/testing'
# Setting the default for sidekiq testing
# many unit-tests rely on this being the default.
# However specs use a different default (inline!)
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
Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
