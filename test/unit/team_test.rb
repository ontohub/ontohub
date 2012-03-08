require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  context 'Associations' do
    should have_many :team_users
    should have_many(:users).through(:team_users)
  end
end
