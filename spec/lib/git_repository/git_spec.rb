require 'spec_helper'

describe "git import" do

  let(:tmpdir){ Pathname.new("/tmp/ontohub/git_test") }
  
  let(:remote_path){ tmpdir.join('remote').to_s }
  let(:remote_repo){ GitRepository.new(remote_path) }
  let(:git_root){ Ontohub::Application.config.git_root }

  let(:commit_count){ 2 }

  let(:user){ create :user }
  let(:userinfo){ {email: user[:email], name: user[:name]} }

  before do
    # clean up
    [tmpdir, git_root].each{|path| path=Pathname.new(path); path.rmtree if path.exist? }
    tmpdir.mkpath

    # create remote repo
    remote_repo

    commit_count.times do |n|
      remote_repo.commit_file(userinfo, "(#{n})", "file-#{n}.clif", "add #{n}")
    end

    @repository = Repository.import_remote('git', user, "file://#{remote_path}", 'local import', description: 'just an imported repo')
    @repository.remote_repository.clone
  end

  it 'be read_only' do
    assert false, 'Test not implemented yet' #TODO
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

      @result = @repository.remote_repository.synchronize
    end

    it 'get the new changes' do
      assert_equal(2*commit_count+1, @repository.commits.size)
      assert_equal @head_oid_pre, @result[:head_oid_pre]
      assert_equal @head_oid_post, @result[:head_oid_post]
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
