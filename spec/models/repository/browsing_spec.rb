require 'spec_helper'

describe 'Repository browsing' do
  let(:user)        { FactoryGirl.create :user }
  let(:repository)  { FactoryGirl.create :repository, user: user }

  let(:files) do {
      'folder1/file1.clif' => "(In Folder)\n",
      'folder1/file2.clf' => "(In2 Folder Too)\n",
      'folder2/file3.clf' => "(In2 Folder Again)\n",
      'inroot1.clif' => "(In1 Root)\n",
      'inroot1.clf' => "(In1 Root Too)\n",
      'inroot2.clif' => "(In2 Root)\n"
    }
  end
  let(:message) { 'test message' }

  before do
    files.each do | path, content |
      tmpfile = Tempfile.new(File.basename(path))
      tmpfile.write(content)
      tmpfile.close

      repository.save_file(tmpfile.path, path, message, user)
    end
  end

  context 'paths_starting_with?' do
    it 'inroot2' do
      expect(repository.paths_starting_with('inroot2')).to eq(['inroot2.clif'])
    end

    it 'inroot' do
      expect(repository.paths_starting_with('inroot')).to eq(['inroot1.clf', 'inroot1.clif', 'inroot2.clif'])
    end

    it 'folder1/file' do
      expect(repository.paths_starting_with('folder1/file')).to eq(['folder1/file1.clif', 'folder1/file2.clf'])
    end
  end

  context 'dir?' do
    it 'non-existent' do
      expect(repository.dir?('non-existent')).to be_falsey
    end

    it 'non-dir' do
      expect(repository.dir?('inroot1.clif')).to be_falsey
    end

    it 'dir' do
      expect(repository.dir?('folder1')).to be_truthy
    end
  end
end
