require 'spec_helper'

describe 'Repository Remote' do
  context 'converting' do
    let(:repository) { create :repository_with_remote }

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
    end
  end

  context 'forking', :process_jobs_synchronously do
    let!(:repository) do
      r = build :repository_with_remote
      r.remote_type = 'fork'
      r.save!
      r.reload
    end

    it 'should be a non-mirrored repository' do
      expect(repository.mirror?).to be_falsy
    end
  end
end
