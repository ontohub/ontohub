require 'open3'

module GitRepository::Cloning
  extend ActiveSupport::Concern

  DIR = File.dirname(__FILE__)
  SCRIPT_REMOTE_SET = "#{DIR}/remote_set_url_push.sh"
  SCRIPT_PUSH       = "#{DIR}/push.sh"
  SCRIPT_PULL       = "#{DIR}/pull.sh"
  SCRIPT_SVN_REBASE = "#{DIR}/svn_rebase.sh"

  # Struct for old and new OID
  Ref = Struct.new(:previous, :current)

  def push
    exec 'git', 'push'
  end

  def clone(url, branch='master')
    exec 'git', 'remote', 'add', 'origin', url
    fetch_and_reset
  end

  def clone_svn(url)
    File.open("#{local_path}/config","a") do |f|
      f.puts '[svn-remote "svn"]'
      f.puts 'url = ' << url
      f.puts 'fetch = :refs/remotes/git-svn'
    end
    fetch_and_reset_svn
  end

  def fetch(remote='origin')
    exec 'git', 'fetch', remote
  end

  def fetch_and_reset(remote='origin', branch='master')
    fetch remote
    reset_branch branch, "#{remote}/#{branch}"
  end

  def fetch_and_reset_svn
    result = exec 'git', 'svn', 'fetch'
    result = reset_branch 'master', "remotes/git-svn"
    result
  end

  def reset_branch(branch, ref)
    exec_with_head_change 'git', 'branch', '-f', branch, ref
  end

  def remote_add_origin(target_path)
    exec 'git', 'remote', 'add', 'origin', target_path
  end

  def remote_set_url_push(target_path)
    exec 'git', 'remote', 'set-url', '--push', 'origin', target_path
  end

  def remote_rm_origin
    exec 'git', 'remote', 'rm', 'origin'
  end

  module ClassMethods
    # clones a git repository into a bare git repository
    def clone_git(source_path, target_path, bare=false)
      if bare
        exec 'git', 'clone', '--bare', source_path, target_path
      else
        exec 'git', 'clone', source_path, target_path
      end
    end

    # clones a git repository into a bare git repository and one with a working copy
    # last parameter (max_revision) is used for testing only
    def clone_svn(source_path, target_path_bare, target_path_working_copy, max_revision=nil)
      if File.exists? target_path_bare
        { out: nil, err: "#{target_path_bare} already exists.", success: false }
      elsif File.exists? target_path_working_copy
        { out: nil, err: "#{target_path_working_copy} already exists.", success: false }
      else
        clone_svn_only(source_path, target_path_working_copy, max_revision)
        return result_svn unless result_svn[:success]

        result_git = clone_git(target_path_working_copy, target_path_bare, true)
        return result_git unless result_git[:success]

        result_remote_rm = GitRepository.new(target_path_bare).remote_rm_origin
        return result_remote_rm unless result_remote_rm[:success]

        result_remote_add = GitRepository.new(target_path_working_copy).remote_add_origin(target_path_bare)
        return result_remote_add unless result_remote_add[:success]

        result_git
      end
    end

    def is_git_repository?(address)
      exec 'git', 'ls-remote', address
    end

    def is_svn_repository?(address)
      exec 'svn', 'ls', address
    end

    protected

    def clone_svn_only(source_path, target_path, max_revision=nil)
      if max_revision.nil?
        exec 'git', 'svn', 'clone', source_path, target_path
      else
        exec 'git', 'svn', 'clone', '-r', "0:#{max_revision}", source_path, target_path
      end
    end

    def exec(*args)
      Subprocess.run *args
    end
  end


  def exec(*args)
    Subprocess.run({GIT_DIR: local_path.to_s}, *args)
  end

  def exec_with_head_change(*args)
    old_oid = head_oid rescue nil
    exec *args
    Ref.new(old_oid, head_oid)
  end

  protected

  def local_path
    if repo.bare?
      repo.path
    else
      repo.path.split('/')[0..-2].join('/')
    end
  end
end
