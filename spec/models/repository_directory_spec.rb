require 'spec_helper'

describe RepositoryDirectory do

  context 'validations' do
    let(:repository_directory) { FactoryGirl.build :repository_directory }
    let(:repository) { repository_directory.repository }
    let(:user) { repository_directory.repository.user }

    it 'should be valid' do
      expect(repository_directory.valid?).to be_truthy
    end

    it 'should fail without a name' do
      repository_directory.name = ''
      expect(repository_directory.valid?).to be_falsy
    end

    it 'should fail with target_directory but without a name' do
      repository_directory.target_directory = 'dir'
      repository_directory.name = ''
      expect(repository_directory.valid?).to be_falsy
    end

    context 'existing tree entry' do
      let(:dirname) { "#{repository_directory.name}-other" }
      let(:filename) { 'file' }
      let(:filepath) { File.join(dirname, filename) }
      before do
        repository.save_file_only(Tempfile.new('tempfile').path, filepath, 'message', user)
      end

      it 'should fail when path is the directory' do
        repository_directory.name = dirname
        expect(repository_directory.valid?).to be_falsy
      end

      it 'should fail when path is the file (with target_directory)' do
        repository_directory.target_directory = dirname
        repository_directory.name = filename
        expect(repository_directory.valid?).to be_falsy
      end

      it 'should fail when path is beneath the file' do
        repository_directory.name = File.join(filepath, 'beneath')
        expect(repository_directory.valid?).to be_falsy
      end

      it 'should fail when path is beneath the file (with target_directory)' do
        repository_directory.target_directory = filepath
        repository_directory.name = 'beneath'
        expect(repository_directory.valid?).to be_falsy
      end
    end
  end

  context 'fields' do
    let(:repository_directory) { FactoryGirl.build :repository_directory }
    it 'path should be target_directory plus name' do
      repository_directory.target_directory = 'dir'
      expect(repository_directory.target_path).
        to eq(File.join(repository_directory.target_directory, repository_directory.name))
    end
  end

  context 'directory creation' do
    let(:repository_directory) { FactoryGirl.build :repository_directory }
    let(:repository) { repository_directory.repository }
    let(:user) { repository_directory.repository.user }

    it 'should create the directory in the git repository' do
      expect(repository.path_exists?(repository_directory.target_path)).to be_falsy
      repository_directory.save
      expect(repository.path_exists?(repository_directory.target_path)).to be_truthy
    end

    it 'should create the directory in the git repository in a subdirectory' do
      repository_directory.target_directory = 'test'
      expect(repository.path_exists?(repository_directory.target_path)).to be_falsy
      repository_directory.save
      expect(repository.path_exists?(repository_directory.target_path)).to be_truthy
    end

    it 'should create a .gitkeep file' do
      repository_directory.save
      expect(repository.path_exists?(File.join(repository_directory.target_path, '.gitkeep'))).
        to be_truthy
    end
  end
end
