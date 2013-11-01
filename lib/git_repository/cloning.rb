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
    set_section %w( svn-remote svn ),
      url:   url,
      fetch: ':refs/remotes/git-svn'
    
    pull_svn
  end

  def pull
    with_head_change do
      git_exec 'remote', 'update'
    end
  end

  # Fetches the latest commits and resets the local master
  def pull_svn
    git_exec 'svn', 'fetch'
    reset_branch 'master', "remotes/git-svn"
  end

  # Sets the reference of a local branch 
  def reset_branch(branch, ref)
    with_head_change do
      git_exec 'branch', '-f', branch, ref
    end
  end

  module ClassMethods
    def is_git_repository?(address)
      exec 'git', 'ls-remote', address
    end

    def is_svn_repository?(address)
      exec 'svn', 'ls', address
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
  def with_head_change(*args)
    old_oid = head_oid rescue nil
    yield
    Ref.new(old_oid, head_oid)
  end

  def local_path
    repo.path
  end
end
