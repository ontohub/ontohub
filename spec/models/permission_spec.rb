require 'spec_helper'

describe Permission do
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
end
