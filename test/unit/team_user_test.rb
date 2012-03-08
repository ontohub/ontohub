require 'test_helper'

class TeamUserTest < ActiveSupport::TestCase
  context 'Associations' do
    should belong_to :team
    should belong_to :user
  end
end
