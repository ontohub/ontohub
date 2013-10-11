require 'open3'

module GitRepository::Cloning
  extend ActiveSupport::Concern

  DIR = File.dirname(__FILE__)
  SCRIPT_REMOTE_ADD = "#{DIR}/remote_add_origin.sh"
  SCRIPT_REMOTE_RM  = "#{DIR}/remote_rm_origin.sh"
  SCRIPT_REMOTE_SET = "#{DIR}/remote_set_url_push.sh"
  SCRIPT_PUSH       = "#{DIR}/push.sh"
  SCRIPT_PULL       = "#{DIR}/pull.sh"
  SCRIPT_SVN_REBASE = "#{DIR}/svn_rebase.sh"

  # runs `git push`
  def push
    stdin, stdout, stderr, wait_thr = Open3.popen3 'bash', SCRIPT_PUSH, local_path

    { out: stdout.gets(nil), err: stderr.gets(nil), success: wait_thr.value.success? }
  end

  # runs `git pull`
  def pull
    head_oid_pre = head_oid
    stdin, stdout, stderr, wait_thr = Open3.popen3 'bash', SCRIPT_PULL, local_path

    { out: stdout.gets(nil), err: stderr.gets(nil), success: wait_thr.value.success?,
      head_oid_pre: head_oid_pre, head_oid_post: head_oid }
  end

  # runs `git svn rebase`
  def svn_rebase
    head_oid_pre = head_oid
    stdin, stdout, stderr, wait_thr = Open3.popen3 'bash', SCRIPT_SVN_REBASE, local_path

    { out: stdout.gets(nil), err: stderr.gets(nil), success: wait_thr.value.success?,
      head_oid_pre: head_oid_pre, head_oid_post: head_oid }
  end

  def is_svn_clone?
    branches.map {|r| r[:refname]}.include? 'refs/remotes/git-svn'
  end

  def remote_add_origin(target_path)
    stdin, stdout, stderr, wait_thr = Open3.popen3 'bash', SCRIPT_REMOTE_ADD, local_path, target_path

    { out: stdout.gets(nil), err:   stderr.gets(nil), success: wait_thr.value.success? }
  end

  def remote_set_url_push(target_path)
    stdin, stdout, stderr, wait_thr = Open3.popen3 'bash', SCRIPT_REMOTE_SET, local_path, target_path

    { out: stdout.gets(nil), err:   stderr.gets(nil), success: wait_thr.value.success? }
  end

  def remote_rm_origin
    stdin, stdout, stderr, wait_thr = Open3.popen3 'bash', SCRIPT_REMOTE_RM, local_path

    { out: stdout.gets(nil), err: stderr.gets(nil), success: wait_thr.value.success? }
  end

  module ClassMethods
    # clones a git repository into a bare git repository
    def clone_git(source_path, target_path, bare=false)
      if bare
        stdin, stdout, stderr, wait_thr = Open3.popen3 'git', 'clone', '--bare', source_path, target_path
      else
        stdin, stdout, stderr, wait_thr = Open3.popen3 'git', 'clone', source_path, target_path
      end

      { out: stdout.gets(nil), err: stderr.gets(nil), success: wait_thr.value.success? }
    end

    # clones a git repository into a bare git repository and one with a working copy
    # last parameter (max_revision) is used for testing only
    def clone_svn(source_path, target_path_bare, target_path_working_copy, max_revision=nil)
      if File.exists? target_path_bare
        { out: nil, err: "#{target_path_bare} already exists.", success: false }
      elsif File.exists? target_path_working_copy
        { out: nil, err: "#{target_path_working_copy} already exists.", success: false }
      else
        result_svn = clone_svn_only(source_path, target_path_working_copy, max_revision)
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
      stdin, stdout, stderr, wait_thr = Open3.popen3 'git', 'ls-remote', address

      wait_thr.value.success?
    end

    def is_svn_repository?(address)
      stdin, stdout, stderr, wait_thr = Open3.popen3 'svn', 'ls', address

      wait_thr.value.success?
    end

    protected

    def clone_svn_only(source_path, target_path, max_revision=nil)
      if max_revision.nil?
        stdin, stdout, stderr, wait_thr = Open3.popen3 'git', 'svn', 'clone', source_path, target_path
      else
        stdin, stdout, stderr, wait_thr = Open3.popen3 'git', 'svn', 'clone', '-r', "0:#{max_revision}", source_path, target_path
      end

      { out: stdout.gets(nil), err: stderr.gets(nil), success: wait_thr.value.success? }
    end
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
