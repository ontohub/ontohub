require 'spec_helper'

describe 'Repository Remote' do
  context 'converting' do
    let(:repository) { create :repository_with_remote, remote_type: 'mirror' }

    it 'should be a mirrored reppository' do
      expect(repository.mirror?).to be_truthy
    end

    context 'convert to local' do
      before do
        repository.convert_to_local!
      end

      it 'should become a non-mirrored repository' do
        expect(repository.mirror?).to be_falsy
      end

      it 'should become a forked repository' do
        expect(repository.fork?).to be_truthy
      end
    end
  end

  context 'forking', :process_jobs_synchronously do
    let!(:repository) { create :repository_with_remote, remote_type: 'fork' }

    it 'should be a non-mirrored repository' do
      expect(repository.mirror?).to be_falsy
    end

    it 'should be a forked repository' do
      expect(repository.fork?).to be_truthy
    end
  end

  context 'remote_type' do
    context 'without source address' do
      let(:repository) { create :repository, remote_type: 'fork' }
      it 'should not have a remote type after saving' do
        expect(repository.remote_type?).to be_falsy
      end
    end

    context 'with source address' do
      let(:repository) { create :repository_with_remote, remote_type: 'fork' }
      it 'should have a remote type after saving' do
        expect(repository.remote_type?).to be_truthy
      end
    end
  end
end
