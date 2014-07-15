require 'spec_helper'

describe "git import" do

  let(:tmpdir){  }

  let(:remote_path){ Pathname.new("/tmp/ontohub/remote") }
  let(:remote_repo){ GitRepository.new(remote_path.to_s) }
  let(:git_root){ Ontohub::Application.config.git_root }
  let(:daemon_root){ Repository::Symlink::PATH }

  let(:commit_count){ 2 }

  let(:user){ create :user }
  let(:userinfo){ {email: user[:email], name: user[:name]} }

  before do
    # clean up
    [remote_path, git_root, daemon_root].each{|path| path=Pathname.new(path); path.rmtree if path.exist? }

    # create remote repo
    remote_repo

    commit_count.times do |n|
      remote_repo.commit_file(userinfo, "(#{n})", "file-#{n}.clif", "add #{n}")
    end

    @repository = Repository.import_remote('git', user, "file://#{remote_path}", 'local import', description: 'just an imported repo')

    # Run clone job
    Worker.drain
  end

  it 'detect that it is not an svn repo' do
    assert !GitRepository.is_svn_repository?(remote_path)
  end

  it 'detect that it is a git repo' do
    assert GitRepository.is_git_repository?(remote_path)
  end

  pending 'read_only'

  it 'set imported_at' do
    @repository.reload.imported_at.should_not == nil
  end

  it 'have all the commits' do
    assert_equal commit_count, @repository.commits.size
  end

  it 'have source-type git' do
    assert_equal 'git', @repository.source_type
  end

  it 'have correct source address' do
    assert_equal "file://#{remote_path}", @repository.source_address
  end

  it 'save the ontologies in the database' do
    assert_equal commit_count, @repository.ontologies.count
  end

  it 'save ontology versions in the database' do
    @repository.ontologies.each do |o|
      assert_equal 1, o.versions.count
    end
  end

  context 'getting synchronized' do
    before do
      @head_oid_pre = remote_repo.head_oid
      remote_repo.commit_file(userinfo, '(and 0 0)', 'file-0.clif', 'change 0')
      commit_count.times do |n|
        m = n+commit_count
        remote_repo.commit_file(userinfo, "(#{m})", "file-#{m}.clif", "add #{m}")
      end
      @head_oid_post = remote_repo.head_oid

      @repository = Repository.find_by_path(@repository.path)#reload the repository
      @repository.user = user # it's crucial to set the user to the current user when synchronizing a repository

      @result = @repository.remote_send :pull
    end

    it 'get the new changes' do
      assert_equal(2*commit_count+1, @repository.commits.size)
      assert_equal @head_oid_pre,  @result.previous
      assert_equal @head_oid_post, @result.current
    end

    it 'save the ontologies in the database' do
      assert_equal 2*commit_count, @repository.ontologies.count
    end

    it 'save ontology versions in the database' do
      @repository.ontologies.each do |o|
        assert_equal(o.path == 'file-0.clif' ? 2 : 1, o.versions.count)
      end
    end
  end

end
