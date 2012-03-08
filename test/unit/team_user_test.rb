require 'test_helper'

class TeamUserTest < ActiveSupport::TestCase
  context 'Associations' do
    should belong_to :team
    should belong_to :user
  end

  context 'Team Users' do
    setup do
      @team_user = Factory :team_user
    end

    should 'have team' do
      assert_not_nil @team_user.team
    end

    should 'be admin, if first' do
      assert @team_user.admin?
    end
  end
end
