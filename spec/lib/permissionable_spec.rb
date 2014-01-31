require 'spec_helper'

describe Permissionable do

  context 'on repository should find the highest permission' do
    let!(:team) { create :team_with_user_and_permission }
    let!(:user) { team.users.first }
    let!(:permission) { team.permissions.first }
    let!(:repository) { permission.item }

    context 'editor through team' do
      it 'should fetch the editor permission' do
        expect(repository.highest_permission(user)).to eq(permission)
      end
    end

    context 'team-editor and user owner' do
      let!(:owner_permission) do
        perm = create :permission, subject: user, item: repository,
          role: 'owner'
        repository.permissions << perm
        user.permissions << perm
        perm
      end

      it 'should fetch the higher owner permission' do
        expect(repository.highest_permission(user)).to eq(owner_permission)
      end
    end

  end

end
