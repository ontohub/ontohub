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
end
