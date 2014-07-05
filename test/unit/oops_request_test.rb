require 'test_helper'

class OopsRequestTest < ActiveSupport::TestCase

  should belong_to :ontology_version
  should have_many :responses

end
