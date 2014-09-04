require 'spec_helper'

describe 'Repository Remote' do
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
