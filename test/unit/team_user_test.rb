require 'test_helper'

class TeamUserTest < ActiveSupport::TestCase
  context 'Associations' do
    should belong_to :team
    should belong_to :user
    should belong_to :creator
  end

  context 'team with admin and user' do
    setup do
      @team_admin = FactoryGirl.create :user # admin in team
      @team_user  = FactoryGirl.create :user # non-admin in team

      @admin_user  = FactoryGirl.create :team_user, :user => @team_admin
      @team        = @admin_user.team

      @team.users << @team_user
      @non_admim_user = @team.team_users.non_admin.first
    end

    should 'have 2 members' do
      assert_equal 2, @team.team_users.count
    end

    should 'have a admin' do
      assert_equal @team_admin, @team.team_users.admin.first.user
    end

    should 'have a non-admin' do
      assert_equal @team_user, @team.team_users.non_admin.first.user
    end

    should 'remove non-admin' do
      assert @non_admim_user.destroy
    end

    should 'not destroy the last admin' do
      assert_raises Permission::PowerVaccuumError do
        assert @admin_user.destroy
      end
    end

    should 'not remove the last admin flag' do
      assert_raises Permission::PowerVaccuumError do
        @admin_user.update_attribute :admin, false
      end
    end
  end
end
