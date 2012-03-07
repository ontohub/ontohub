require 'test_helper'

class EntityTest < ActiveSupport::TestCase
  should belong_to :ontology
  should have_and_belong_to_many :axioms
end
