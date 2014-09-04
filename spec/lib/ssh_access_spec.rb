require 'spec_helper'

describe SSHAccess do

  let(:permission) { create :permission, role: 'reader' }
  let(:user) { permission.subject }
  let(:repository) { permission.item }

  context 'without a permission' do

    it 'should allow read on public readable repository' do
      repository.access = 'public_r'
      access = described_class.determine_permission('read', nil, repository)
      expect(access).to be true
    end

    it 'should disallow write on public readable repository' do
      repository.access = 'public_r'
      access = described_class.determine_permission('write', nil, repository)
      expect(access).to be false
    end

    it 'should allow read on public read-writeable repository' do
      repository.access = 'public_rw'
      access = described_class.determine_permission('read', nil, repository)
      expect(access).to be true
    end

    it 'should allow write on public read-writeable repository' do
      repository.access = 'public_rw'
      access = described_class.determine_permission('write', nil, repository)
      expect(access).to be true
    end

    it 'should disallow read on private readable repository' do
      repository.access = 'private_r'
      access = described_class.determine_permission('read', nil, repository)
      expect(access).to be false
    end

    it 'should disallow write on private readable repository' do
      repository.access = 'private_r'
      access = described_class.determine_permission('write', nil, repository)
      expect(access).to be false
    end

    it 'should disallow read on private read-writeable repository' do
      repository.access = 'private_rw'
      access = described_class.determine_permission('read', nil, repository)
      expect(access).to be false
    end

    it 'should disallow write on private read-writeable repository' do
      repository.access = 'private_rw'
      access = described_class.determine_permission('write', nil, repository)
      expect(access).to be false
    end

    it 'should raise error on write to mirror repository' do
      repository.source_address = 'http://some_source_address.example.com'
      repository.source_type = 'git'
      expect { described_class.determine_permission('write', nil, repository) }.
        to raise_error(SSHAccess::InvalidAccessOnMirrorError)
    end

  end

  context 'with permission' do

    context 'denoting owner rights' do
      let(:permission) { create :permission, role: 'owner' }

      it 'should allow write on public readable repository' do
        repository.access = 'public_r'
        access = described_class.determine_permission('write', permission, repository)
        expect(access).to be true
      end

      it 'should allow write on private readable repository' do
        repository.access = 'private_r'
        access = described_class.determine_permission('write', permission, repository)
        expect(access).to be true
      end

      it 'should raise error on write to mirror repository' do
        repository.source_address = 'http://some_source_address.example.com'
        repository.source_type = 'git'
        expect { described_class.determine_permission('write', permission, repository) }.
          to raise_error(SSHAccess::InvalidAccessOnMirrorError)
      end
    end

    context 'denoting editor rights' do
      let(:permission) { create :permission, role: 'editor' }

      it 'should allow write on public readable repository' do
        repository.access = 'public_r'
        access = described_class.determine_permission('write', permission, repository)
        expect(access).to be true
      end

      it 'should allow write on private readable repository' do
        repository.access = 'private_r'
        access = described_class.determine_permission('write', permission, repository)
        expect(access).to be true
      end

      it 'should raise error on write to mirror repository' do
        repository.source_address = 'http://some_source_address.example.com'
        repository.source_type = 'git'
        expect { described_class.determine_permission('write', permission, repository) }.
          to raise_error(SSHAccess::InvalidAccessOnMirrorError)
      end
    end

    it 'should allow read on public readable repository' do
      repository.access = 'public_r'
      access = described_class.determine_permission('read', permission, repository)
      expect(access).to be true
    end

    it 'should disallow write on public readable repository' do
      repository.access = 'public_r'
      access = described_class.determine_permission('write', permission, repository)
      expect(access).to be false
    end

    it 'should allow read on public read-writeable repository' do
      repository.access = 'public_rw'
      access = described_class.determine_permission('read', permission, repository)
      expect(access).to be true
    end

    it 'should allow write on public read-writeable repository' do
      repository.access = 'public_rw'
      access = described_class.determine_permission('write', permission, repository)
      expect(access).to be true
    end

    it 'should allow read on private readable repository' do
      repository.access = 'private_r'
      access = described_class.determine_permission('read', permission, repository)
      expect(access).to be true
    end

    it 'should disallow write on private readable repository' do
      repository.access = 'private_r'
      access = described_class.determine_permission('write', permission, repository)
      expect(access).to be false
    end

    it 'should allow read on private read-writeable repository' do
      repository.access = 'private_rw'
      access = described_class.determine_permission('read', permission, repository)
      expect(access).to be true
    end

    it 'should allow write on private read-writeable repository' do
      repository.access = 'private_rw'
      access = described_class.determine_permission('write', permission, repository)
      expect(access).to be true
    end

    it 'should raise error on write to mirror repository' do
      repository.source_address = 'http://some_source_address.example.com'
      repository.source_type = 'git'
      expect { described_class.determine_permission('write', permission, repository) }.
        to raise_error(SSHAccess::InvalidAccessOnMirrorError)
    end
  end

end
