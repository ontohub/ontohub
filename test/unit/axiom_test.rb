require 'test_helper'

class AxiomTest < ActiveSupport::TestCase
  should belong_to :ontology
  should have_and_belong_to_many :entities
end
