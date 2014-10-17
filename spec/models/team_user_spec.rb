require 'spec_helper'

describe TeamUser do
  context 'Associations' do
    %i(team user creator).each do |association|
      it { should belong_to(association) }
    end
  end

  context 'team with admin and user' do
    let(:team_admin) { create :user } # admin in team
    let(:team_user) { create :user } # non-admin in team
    let(:admin_user) { create :team_user, user: team_admin }
    let(:team) { admin_user.team }
    let(:non_admim_user) { team.team_users.non_admin.first }
    before { team.users << team_user }

    it 'have 2 members' do
      expect(team.team_users.count).to eq(2)
    end

    it 'have a admin' do
      expect(team.team_users.admin.first.user).to eq(team_admin)
    end

    it 'have a non-admin' do
      expect(team.team_users.non_admin.first.user).to eq(team_user)
    end

    it 'remove non-admin' do
      expect(non_admim_user.destroy).to be_truthy
    end

    it 'not destroy the last admin' do
      expect { assert admin_user.destroy }.
        to raise_error(Permission::PowerVaccuumError)
    end

    it 'not remove the last admin flag' do
      expect { admin_user.update_attribute :admin, false }.
        to raise_error(Permission::PowerVaccuumError)
    end
  end
end
