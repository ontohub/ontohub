require 'spec_helper'

def exec_silently(cmd)
  Subprocess.run('bash', '-c', cmd)
end

def commit(work_dir, count, prefix)
  Dir.chdir(work_dir) do
    count.times do |n|
      file = "#{prefix}#{n}.txt"
      File.write(file, Time.now.to_s)
      exec_silently("svn add --force #{file}")
      exec_silently("svn ci -m 'add #{file}'")
    end
  end
end

describe "svn import" do
  let!(:svn_repo_paths) { create :svn_repository }
  let(:bare_url) { "file://#{svn_repo_paths.first}" }
  let(:work_dir) { svn_repo_paths.last }

  let(:commit_count){ 2 }

  let(:user){ create :user }
  let!(:repository) do
    Repository.import_remote(
      'svn',
      user,
      bare_url,
      'local import',
      description: 'just an imported repo',
      remote_type: 'mirror')
  end

  before do
    commit(work_dir, commit_count, '')
    Worker.drain
  end


  it 'detect that it is an svn repo' do
    expect(GitRepository.is_svn_repository?(bare_url)).to be_truthy
  end

  it 'detect that it is not a git repo' do
    expect(GitRepository.is_git_repository?(bare_url)).to be_falsy
  end

  it 'have all the commits' do
    expect(repository.commits.size).to eq(commit_count)
  end

  context 'synchronizing without new commits' do
    let!(:result) { repository.remote_send :pull }

    it 'unchanged HEAD' do
      expect(result.current).to eq(result.previous)
    end
  end


  context 'adding commits to svn' do
    before { commit(work_dir, commit_count, 'new_') }
    let!(:result) { repository.remote_send :pull }

    it 'get the new commits' do
      expect(repository.commits.size).to eq(commit_count * 2)
    end

    it 'changed HEAD' do
      expect(result.current).not_to eq(result.previous)
    end
  end
end
