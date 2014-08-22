require 'spec_helper'

describe 'GitRepositoryDirectories' do

  ENV['LANG'] = 'C'

  let(:path) { '/tmp/ontohub/test/unit/git/repository' }
  let(:repository) { GitRepository.new(path) }
  let(:userinfo) { {email: 'jan@jansson.com', name: 'Jan Jansson', time: Time.now} }


  let(:subfolder) { 'path' }
  let(:filepath1) { "#{subfolder}/file1.txt" }
  let(:filepath2) { "#{subfolder}/file2.txt" }
  let(:filepath3) { 'file3.txt' }
  let(:content) { 'Some content' }
  let(:message1) { 'Some commit message1' }
  let(:message2) { 'Some commit message2' }
  let(:message3) { 'Some commit message3' }

  before do
    @commit_add1 = repository.commit_file(userinfo, content, filepath1, message1)
    @commit_add2 = repository.commit_file(userinfo, content, filepath2, message2)
    @commit_add3 = repository.commit_file(userinfo, content, filepath3, message3)
    @commit_del1 = repository.delete_file(userinfo, filepath1)
    @commit_del2 = repository.delete_file(userinfo, filepath2)
    @commit_del3 = repository.delete_file(userinfo, filepath3)
  end

  after do
    FileUtils.rmtree(path) if File.exists?(path)
  end


  it 'read the right number of contents in the root folder after adding the first file' do
    expect(repository.folder_contents(@commit_add1).size).to eq(1)
  end

  it 'read the right contents in the root folder after adding the first file' do
    expect(repository.folder_contents(@commit_add1).map do |git_file|
      { type: git_file.type, path: git_file.path }
    end).to eq([{
      type: :dir,
      path: subfolder
    }])
  end

  it 'read the right number of contents in the subfolder after adding the first file' do
    expect(repository.folder_contents(@commit_add1, subfolder).size).to eq(1)
  end

  it 'read the right contents in the subfolder after adding the first file' do
    expect(repository.folder_contents(@commit_add1, subfolder).map do |git_file|
      { type: git_file.type, path: git_file.path }
    end).to eq([{
      type: :file,
      path: filepath1
    }])
  end


  it 'read the right number of contents in the root folder after adding the second file' do
    expect(repository.folder_contents(@commit_add2).size).to eq(1)
  end

  it 'read the right contents in the root folder after adding the second file' do
    expect(repository.folder_contents(@commit_add2).map do |git_file|
      { type: git_file.type, path: git_file.path }
    end).to eq([{
      type: :dir,
      path: subfolder
    }])
  end

  it 'read the right number of contents in the subfolder after adding the second file' do
    expect(repository.folder_contents(@commit_add2, subfolder).size).to eq(2)
  end

  it 'read the right contents in the subfolder after adding the second file' do
    expect(repository.folder_contents(@commit_add2, subfolder).map do |git_file|
      { type: git_file.type, path: git_file.path }
    end).to eq([{
      type: :file,
      path: filepath1
    },{
      type: :file,
      path: filepath2
    }])
  end


  it 'read the right number of contents in the root folder after adding the third file' do
    expect(repository.folder_contents(@commit_add3).size).to eq(2)
  end

  it 'read the right contents in the root folder after adding the third file' do
    expect(repository.folder_contents(@commit_add3).map do |git_file|
      { type: git_file.type, path: git_file.path }
    end).to eq([{
      type: :dir,
      path: subfolder
    },{
      type: :file,
      path: filepath3
    }])
  end

  it 'read the right number of contents in the subfolder after adding the third file' do
    expect(repository.folder_contents(@commit_add3, subfolder).size).to eq(2)
  end

  it 'read the right contents in the subfolder after adding the third file' do
    expect(repository.folder_contents(@commit_add3, subfolder).map do |git_file|
      { type: git_file.type, path: git_file.path }
    end). to eq([{
      type: :file,
      path: filepath1
    },{
      type: :file,
      path: filepath2
    }])
  end

  it 'treat path "/" and empty path equally' do
    expect(repository.folder_contents(@commit_add3, '/')).to eq(repository.folder_contents(@commit_add3))
  end

  it 'treat path "/" and empty path equally (with nil)' do
    expect(repository.folder_contents(@commit_add3, '/')).to eq(repository.folder_contents(@commit_add3, nil))
  end


  it 'read the right number of contents in the root folder after deleting the first file' do
    expect(repository.folder_contents(@commit_del1).size).to eq(2)
  end

  it 'read the right contents in the root folder after deleting the first file' do
    expect(repository.folder_contents(@commit_del1).map do |git_file|
      { type: git_file.type, path: git_file.path }
    end).to eq([{
      type: :dir,
      path: subfolder
    },{
      type: :file,
      path: filepath3
    }])
  end

  it 'read the right number of contents in the subfolder after deleting the first file' do
    expect(repository.folder_contents(@commit_del1, subfolder).size).to eq(1)
  end

  it 'read the right contents in the subfolder after deleting the first file' do
    expect(repository.folder_contents(@commit_del1, subfolder).map do |git_file|
      { type: git_file.type, path: git_file.path }
    end).to eq([{
      type: :file,
      path: filepath2
    }])
  end


  it 'read the right number of contents in the root folder after deleting the second file' do
    expect(repository.folder_contents(@commit_del2).size).to eq(1)
  end

  it 'read the right contents in the root folder after deleting the second file' do
    expect(repository.folder_contents(@commit_del2).map do |git_file|
      { type: git_file.type, path: git_file.path }
    end).to eq([{
      type: :file,
      path: filepath3
    }])
  end


  it 'read the right number of contents in the root folder after deleting the third file' do
    expect(repository.folder_contents(@commit_del3).size).to eq(0)
  end

  it 'read the right contents in the root folder after deleting the third file' do
    expect(repository.folder_contents(@commit_del3)).to eq([])
  end

  context 'process all files by files method' do
    let(:files) { [] }
    before do
      repository.files do |git_file|
        files << [git_file.path, git_file.last_change[:oid]]
      end
    end

    it { expect(files).to eq([]) }

    context 'at commit_add3' do
      before do
        repository.files(@commit_add3) do |git_file|
          files << [git_file.path, git_file.last_change[:oid]]
        end
      end

      it do
        expect(files).to eq([
          [filepath1, @commit_add1],
          [filepath2, @commit_add2],
          [filepath3, @commit_add3] ])
      end
    end
  end
end
