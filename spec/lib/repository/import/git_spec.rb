require 'spec_helper'

describe "git import" do
  let(:user){ create :user }
  let(:userinfo){ {email: user[:email], name: user[:name]} }

  let!(:remote_repo){ create :git_repository_with_commits }
  let!(:commit_count){ remote_repo.commits.size }

  let!(:repository) do
    Repository.import_remote(
      'git',
      user,
      "file://#{remote_repo.path}",
      'local import',
      description: 'just an imported repo',
      remote_type: 'mirror')
  end

  before { Worker.drain }

  it 'detect that it is not an svn repo' do
    expect(GitRepository.is_svn_repository?(remote_repo.path)).to be_falsy
  end

  it 'detect that it is a git repo' do
    expect(GitRepository.is_git_repository?(remote_repo.path)).to be_truthy
  end

  it 'set imported_at' do
    expect(repository.reload.imported_at).not_to be_nil
  end

  it 'have all the commits' do
    expect(repository.commits.size).to eq(remote_repo.commits.size)
  end

  it 'have source-type git' do
    expect(repository.source_type).to eq('git')
  end

  it 'have correct source address' do
    expect(repository.source_address).to eq("file://#{remote_repo.path}")
  end

  it 'save the ontologies in the database' do
    expect(repository.ontologies.size).to eq(commit_count)
  end

  it 'save ontology versions in the database' do
    repository.ontologies.each do |o|
      expect(o.versions.size).to eq(1)
    end
  end

  let!(:head_oid_pre) { remote_repo.head_oid }
  context 'getting synchronized' do
    before do
      remote_repo.commit_file(userinfo, '(and 0 0)', 'file-0.clif', 'change 0')
      commit_count.times do |n|
        m = n + commit_count
        remote_repo.commit_file(userinfo, "(#{m})", "file-#{m}.clif", "add #{m}")
      end
    end
    let!(:result) { repository.remote_send :pull }

    context 'get the new changes' do
      let!(:head_oid_post) { remote_repo.head_oid }

      it 'have right commit count' do
        expect(repository.commits.size).to eq(remote_repo.commits.size)
      end

      it 'return correct previous-head' do
        expect(result.previous).to eq(head_oid_pre)
      end

      it 'return the correct current-head' do
        expect(result.current).to eq(head_oid_post)
      end
    end

    it 'save the ontologies in the database' do
      expect(repository.ontologies.size).to eq(2 * commit_count)
    end

    it 'save ontology versions in the database' do
      repository.ontologies.each do |o|
        expect(o.versions.size).to eq(o.path == 'file-0.clif' ? 2 : 1)
      end
    end
  end
end
