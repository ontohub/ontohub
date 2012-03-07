require 'test_helper'

class OntologyTest < ActiveSupport::TestCase
  should belong_to :logic
  should have_many :versions
end
