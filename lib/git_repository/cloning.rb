require 'open3'

module GitRepository::Cloning
  extend ActiveSupport::Concern

  DIR = File.dirname(__FILE__)
  SCRIPT_REMOTE_ADD = "#{DIR}/remote_add_origin.sh"
  SCRIPT_REMOTE_RM  = "#{DIR}/remote_rm_origin.sh"
  SCRIPT_PUSH       = "#{DIR}/push.sh"
  SCRIPT_PULL       = "#{DIR}/pull.sh"
  SCRIPT_SVN_REBASE = "#{DIR}/svn_rebase.sh"

  # runs `git push`
  def push
    stdin, stdout, stderr, wait_thr = Open3.popen3 'sh', SCRIPT_PUSH, repo.path

    { out: stdout.gets(nil), err: stderr.gets(nil), success: wait_thr.value.success? }
  end

  # runs `git pull`
  def pull
    stdin, stdout, stderr, wait_thr = Open3.popen3 'sh', SCRIPT_PULL, repo.path

    { out: stdout.gets(nil), err: stderr.gets(nil), success: wait_thr.value.success? }
  end

  # runs `git svn rebase`
  def svn_rebase
    stdin, stdout, stderr, wait_thr = Open3.popen3 'sh', SCRIPT_SVN_REBASE, repo.path.split('/')[0..-2].join('/')

    { out: stdout.gets(nil), err: stderr.gets(nil), success: wait_thr.value.success? }
  end

  def is_svn_clone?
    branches.map {|r| r[:refname]}.include? 'refs/remotes/git-svn'
  end

  module ClassMethods
    # clones a git repository into a bare git repository
    def clone_git(source_path, target_path)
      stdin, stdout, stderr, wait_thr = Open3.popen3 'git', 'clone', '--bare', source_path, target_path

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

        result_git = clone_git(target_path_working_copy, target_path_bare)
        return result_git unless result_git[:success]

        result_remote_rm = remote_rm_origin(target_path_bare)
        return result_remote_rm unless result_remote_rm[:success]

        result_remote_add = remote_add_origin(target_path_working_copy, target_path_bare)
        return result_remote_add unless result_remote_add[:success]

        result_git
      end
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

    def remote_add_origin(source_path, target_path)
      stdin, stdout, stderr, wait_thr = Open3.popen3 'sh', SCRIPT_REMOTE_ADD, source_path, target_path

      { out: stdout.gets(nil), err:   stderr.gets(nil), success: wait_thr.value.success? }
    end

    def remote_rm_origin(path)
      stdin, stdout, stderr, wait_thr = Open3.popen3 'sh', SCRIPT_REMOTE_RM, path

      { out: stdout.gets(nil), err: stderr.gets(nil), success: wait_thr.value.success? }
    end
  end
end
