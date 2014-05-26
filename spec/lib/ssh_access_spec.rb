require 'spec_helper'

describe SshAccess do

  let(:permission) { create :permission }
  let(:user) { permission.subject }
  let(:repository) { permission.item }

  context 'without a permission' do

    it 'should allow read on public readable repository' do
      repository.access = 'public_r'
      access = described_class.determine_permission('read', nil, repository)
      expect(access).to be_true
    end

    it 'should disallow write on public readable repository' do
      repository.access = 'public_r'
      access = described_class.determine_permission('write', nil, repository)
      expect(access).to be_false
    end

    it 'should allow read on public read-writeable repository' do
      repository.access = 'public_rw'
      access = described_class.determine_permission('read', nil, repository)
      expect(access).to be_true
    end

    it 'should allow write on public read-writeable repository' do
      repository.access = 'public_rw'
      access = described_class.determine_permission('write', nil, repository)
      expect(access).to be_true
    end

    it 'should disallow read on private readable repository' do
      repository.access = 'private_r'
      access = described_class.determine_permission('read', nil, repository)
      expect(access).to be_false
    end

    it 'should disallow write on private readable repository' do
      repository.access = 'private_r'
      access = described_class.determine_permission('write', nil, repository)
      expect(access).to be_false
    end

    it 'should disallow read on private read-writeable repository' do
      repository.access = 'private_rw'
      access = described_class.determine_permission('read', nil, repository)
      expect(access).to be_false
    end

    it 'should disallow write on private read-writeable repository' do
      repository.access = 'private_rw'
      access = described_class.determine_permission('write', nil, repository)
      expect(access).to be_false
    end

  end

  context 'with permission' do

    it 'should allow read on public readable repository' do
      repository.access = 'public_r'
      access = described_class.determine_permission('read', permission, repository)
      expect(access).to be_true
    end

    it 'should disallow write on public readable repository' do
      repository.access = 'public_r'
      access = described_class.determine_permission('write', permission, repository)
      expect(access).to be_false
    end

    it 'should allow read on public read-writeable repository' do
      repository.access = 'public_rw'
      access = described_class.determine_permission('read', permission, repository)
      expect(access).to be_true
    end

    it 'should allow write on public read-writeable repository' do
      repository.access = 'public_rw'
      access = described_class.determine_permission('write', permission, repository)
      expect(access).to be_true
    end

    it 'should allow read on private readable repository' do
      repository.access = 'private_r'
      access = described_class.determine_permission('read', permission, repository)
      expect(access).to be_true
    end

    it 'should disallow write on private readable repository' do
      repository.access = 'private_r'
      access = described_class.determine_permission('write', permission, repository)
      expect(access).to be_false
    end

    it 'should allow read on private read-writeable repository' do
      repository.access = 'private_rw'
      access = described_class.determine_permission('read', permission, repository)
      expect(access).to be_true
    end

    it 'should allow write on private read-writeable repository' do
      repository.access = 'private_rw'
      access = described_class.determine_permission('write', permission, repository)
      expect(access).to be_true
    end
  end

end
