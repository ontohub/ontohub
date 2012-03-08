require 'test_helper'

class PermissionTest < ActiveSupport::TestCase
  context 'Associations' do
    should belong_to :ontology
    should belong_to :owner
  end
end
