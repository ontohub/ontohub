require 'subprocess'

module GitRepository::Cloning
  extend ActiveSupport::Concern

  # Struct for old and new OID
  Ref = Struct.new(:previous, :current)

  def clone(url)
    set_section %w( remote origin ),
      url:    url,
      fetch:  '+refs/*:refs/*',
      mirror: 'true'

    pull
  end

  def clone_svn(url)
    options = { url: url }

    # Do we have a standard layout?
    if self.class.svn_ls(url).split("\n") == %w( branches/ tags/ trunk/ )
      options.merge! \
        fetch:    'trunk:refs/remotes/trunk',
        branches: 'branches/*:refs/remotes/*',
        tags:     'tags/*:refs/remotes/tags/*'
    else
      options.merge! \
        fetch:    ':refs/remotes/git-svn'
    end

    set_section %w( svn-remote svn ), options
    pull_svn
  end

  def pull
    with_head_change head_oid do
      git_exec 'remote', 'update'
    end
  end

  # Fetches the latest commits and resets the local master
  def pull_svn
    old_head_oid = head_oid
    git_exec 'svn', 'fetch'

    if svn_has_trunk?
      reset_branch old_head_oid, 'master', "remotes/trunk"
    else
      reset_branch old_head_oid, 'master', "remotes/git-svn"
    end

  end

  def svn_has_trunk?
    get_config('svn-remote.svn.fetch').starts_with?('trunk:')
  end

  # Sets the reference of a local branch
  def reset_branch(old_head_oid, branch, ref)
    with_head_change old_head_oid do
      git_exec 'branch', '-f', branch, ref
    end
  end

  module ClassMethods
    def is_git_repository?(address)
      !!(exec 'git', 'ls-remote', address)
    rescue Subprocess::Error => e
      if e.status == 128
        false
      else
        raise e
      end
    end

    def svn_ls(address)
      exec 'svn', 'ls', address
    end

    def is_svn_repository?(address)
      svn_ls address
      true
    rescue Subprocess::Error
      false
    end

    def exec(*args)
      Subprocess.run *args
    end
  end

  protected

  # Executes a git command
  def git_exec(*args)
    args.unshift 'git'
    args.push \
      GIT_DIR: local_path.to_s,
      LANG:    'C'

    Subprocess.run *args
  end

  # Yields the given block and returns the head OID
  # before and after yielding the block.
  def with_head_change(old_head_oid, *args)
    yield
    Ref.new(old_head_oid, head_oid)
  end

  def local_path
    repo.path
  end
end
