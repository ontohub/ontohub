require 'spec_helper'

describe 'diff' do
  let(:repository) { create :repository }
  let(:git_repository) { repository.git }
  let(:userinfo) do
    {
      email: 'janjansson.com',
      name: 'Jan Jansson',
      time: Time.now
    }
  end

  let (:content1) { "Some\ncontent\nwith\nmany\nlines." }
  let (:content2) { "Some\ncontent,\nwith\nmany\nlines." }
  let (:filepath) { Pathname.new 'path/to/file.xml'.to_s }

  context 'large diff' do
    before do
      allow(Settings).to receive(:max_combined_diff_size).and_return(0)
      @commit1 = git_repository.commit_file(userinfo, content1, filepath.to_s, 'Message1')
      @commit2 = git_repository.commit_file(userinfo, content2, filepath.to_s, 'Message2')
    end

    let(:diff) { Diff.new(repository_id: repository.path, ref: @commit2) }

    it 'have :diff_too_large in the changed_files' do
      diff.compute
      expect(diff.changed_files.first.diff).to eq(:diff_too_large)
    end
  end
end
