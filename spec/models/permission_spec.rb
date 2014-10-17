require 'spec_helper'

describe Permission do
  context 'associations' do
    %i(creator item subject).each do |association|
      it { should belong_to(association) }
    end
  end

  context 'validations' do
    %w(owner editor).each do |val|
      it { should allow_value(val).for :role }
    end

    [ nil, '','foo' ].each do |val|
      it { should_not allow_value(val).for :role }
    end
  end

  let(:owner)      { create :user }
  let(:permission) { create(:permission, subject: owner, role: 'owner') }

  context 'one owner' do
    it 'should not be possible to remove him' do
      expect{ permission.destroy }.to raise_error(Permission::PowerVaccuumError)
    end

    it 'should not be possible to degrade his role' do
      permission.role = 'editor'
      expect(permission).not_to be_valid
    end

    %w(editor reader).each do |role|
      it "should be possible to remove a #{role} permission" do
        other_permission = create(:permission, subject: owner, role: role)
        expect{ other_permission.destroy }.not_to raise_error
      end
    end
  end

  context 'many owners' do
    let(:other_owner)      { create(:user) }
    before do
      create(:permission, subject: other_owner, role: 'owner', item: permission.item)
    end

    it 'should be possible to remove one' do
      expect{ permission.destroy }.not_to raise_error
    end

    it 'should be possible to degrade his role' do
      permission.role = 'editor'
      expect(permission).to be_valid
    end
  end

  context 'repository' do
    let(:repository) { create :repository }

    context 'admin user' do
      let(:admin) { create :admin }

      %i(owner editor).each do |perm|
        it "have #{perm} permission" do
          expect(repository.permission?(perm, admin)).to be(true)
        end
      end
    end

    context 'owner user' do
      let(:permission) { create :permission, item: repository }

      %i(owner editor).each do |perm|
        it "have #{perm} permission" do
          expect(repository.permission?(perm, permission.subject)).to be(true)
        end
      end
    end

    context 'editor user' do
      let(:permission) do
        create :permission,
          item: repository, role: 'editor'
      end

      it 'not have owner permission' do
        expect(repository.permission?(:owner, permission.subject)).to be(false)
      end

      it 'have editor permission' do
        expect(repository.permission?(:editor, permission.subject)).to be(true)
      end
    end

    context 'team user' do
      let(:team_user) { create :team_user }
      let!(:permission) do
        create :permission,
          item: repository, subject: team_user.team
      end

      %i(owner editor).each do |perm|
        it "have #{perm} permission" do
          expect(repository.permission?(perm, team_user.user)).to be(true)
        end
      end
    end

    context 'bernd' do
      %i(owner editor).each do |perm|
        it "not have #{perm} permission" do
          expect(repository.permission?(perm, nil)).to be(false)
        end
      end
    end

    context 'user on other team' do
      let(:team_user) { create :team_user }
      let(:permission) { create :permission, item: repository }

      %i(owner editor).each do |perm|
        it "not have #{perm} permission" do
          expect(repository.permission?(perm, team_user.user)).to be(false)
        end
      end
    end

    context 'some user' do
      let(:user) { create :user }

      %i(owner editor).each do |perm|
        it "not have #{perm} permission" do
          expect(repository.permission?(perm, user)).to be(false)
        end
      end
    end
  end
end
