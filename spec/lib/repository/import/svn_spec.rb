require 'spec_helper'

describe "svn import" do

  SCRIPT_DIR = Rails.root.join("spec","scripts")
  SCRIPT_SVN_CREATE_REPO = SCRIPT_DIR.join("svn_create_repo.sh")
  SCRIPT_SVN_ADD_COMMITS = SCRIPT_DIR.join("svn_add_commits.sh")

  let(:tmpdir){ Pathname.new("/tmp/ontohub/svn_test") }
  let(:git_root){ Ontohub::Application.config.git_root }
  let(:daemon_root){ Repository::Symlink::PATH }

  let(:svn_baredir){ tmpdir.join('svn_bare') }
  let(:svn_workdir){ tmpdir.join('svn_work') }
  let(:svn_url){ "file://#{svn_baredir}" }

  let(:user){ create :user }
  let(:commit_count){ 2 }

  before do
    # clean up
    [git_root, daemon_root, tmpdir].each{|path| path=Pathname.new(path); path.rmtree if path.exist? }

    # create svn repo
    Subprocess.run SCRIPT_SVN_CREATE_REPO, svn_baredir, svn_workdir
    Subprocess.run SCRIPT_SVN_ADD_COMMITS, svn_workdir, commit_count

    @repository = Repository.import_remote('svn', user, svn_url, 'local import', description: 'just an imported repo')

    # Run clone job
    Worker.drain
  end

  after do
    tmpdir.rmtree
  end

  it 'detect that it is an svn repo' do
    assert GitRepository.is_svn_repository?(svn_url)
  end

  it 'detect that it is not a git repo' do
    assert !GitRepository.is_git_repository?(svn_url)
  end

  it 'have all the commits' do
    assert_equal commit_count, @repository.commits.size
  end

  context 'synchronizing without new commits' do
    before do
      @result = @repository.remote_send :pull
    end

    it 'unchaned HEAD' do
      @result.previous.should == @result.current
    end
  end


  context 'adding commits to svn' do
    before do
      Subprocess.run SCRIPT_SVN_ADD_COMMITS, svn_workdir, commit_count, 'new_'

      @result = @repository.remote_send :pull
    end

    it 'get the new commits' do
      assert_equal commit_count*2, @repository.commits.size
    end

    it 'changed HEAD' do
      @result.previous.should_not == @result.current
    end
  end
end
