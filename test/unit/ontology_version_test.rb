require 'test_helper'

class OntologyVersionTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :ontology
end
