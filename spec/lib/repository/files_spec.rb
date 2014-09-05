require 'spec_helper'

describe 'GitRepositoryFiles' do

  ENV['LANG'] = 'C'

  let(:path) { '/tmp/ontohub/test/unit/git/repository' }
  let(:repository) { GitRepository.new(path) }
  let(:userinfo) { {email: 'jan@jansson.com', name: 'Jan Jansson', time: Time.now} }

  let(:filepath) { 'path/file.txt' }
  let(:content)  { 'Some content' }
  let(:message)  { 'Some commit message' }

  after do
    FileUtils.rmtree(path) if File.exists?(path)
  end

  context 'create single commit of a file' do
    before { repository.commit_file(userinfo, content, filepath, message) }

    it { expect(repository.path_exists?(filepath)).to be_true }
    it { expect(repository.get_file(filepath).name).to eq(filepath.split('/')[-1]) }
    it { expect(repository.get_file(filepath).content).to eq(content) }
    it { expect(repository.get_file(filepath).mime_type).to eq(Mime::Type.lookup('text/plain')) }
    it { expect(repository.commit_message).to eq(message) }
    it { expect(repository.commit_author[:name]).to eq(userinfo[:name]) }
    it { expect(userinfo[:email]).to eq(userinfo[:email]) }
  end

  context 'delete a file' do
    before do
      repository.commit_file(userinfo, content, filepath, message)
      repository.delete_file(userinfo, filepath)
    end

    it { expect(repository.path_exists?(filepath)).to be_false }
  end

  context 'overwrite a file' do
    let(:content2) { "#{content}_2" }
    let(:message2) { "#{message}_2" }

    before do
      repository.commit_file(userinfo, content, filepath, message)
      @first_commit_oid = repository.head_oid
      repository.commit_file(userinfo, content2, filepath, message2)
    end

    it { expect(repository.get_file(filepath).content).to eq(content2) }
    it { expect(repository.commit_message(repository.head_oid)).to eq(message2) }
    it { expect(@first_commit_oid).not_to eq(repository.head_oid) }
  end

  context 'have test if path points through a file' do
    let(:folder) { "folder/1" }
    let(:fullpath) { "#{folder}/#{filepath}" }

    before { repository.commit_file(userinfo, content, fullpath, message) }

    it { expect(repository.points_through_file?(folder)).to be_false }
    it { expect(repository.points_through_file?(fullpath)).to be_false }
    it { expect(repository.points_through_file?("#{fullpath}/foo")).to be_true }
  end

  context 'throw Exception on erroneous paths' do
    before { repository.commit_file(userinfo, content, filepath, message) }

    it do
      expect do
        repository.commit_file(userinfo, content, "#{filepath}/foo", message)
      end.to raise_error(GitRepository::PathBelowFileException)
    end
  end

  context 'reset state on empty repository with failing commit block' do
    it do
      expect do
        repository.commit_file(userinfo, content, filepath, message) do
          raise Exception
        end
      end.to raise_error
    end
  end

  context 'reset state with failing commit block' do
    before do
      @first_commit_oid = repository.commit_file(userinfo, content, filepath, message)

      begin
        repository.commit_file(userinfo, "#{content}!", filepath, message) do
          raise Exception
        end
      rescue Exception
      end
    end
    #feature not implemented yet:
    it 'feature not implemented yet' do
      pending { expect(@first_commit_oid).to eq(repository.head_oid) }
    end
  end
end
