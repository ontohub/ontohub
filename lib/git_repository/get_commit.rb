module GitRepository::GetCommit
  # depends on GitRepository
  extend ActiveSupport::Concern

  # returns the commit message of a commit
  def commit_message(commit_oid = nil)
    get_commit(commit_oid).message unless @repo.empty?
  end

  # returns the author of a commit
  def commit_author(commit_oid = nil)
    get_commit(commit_oid).author unless @repo.empty?
  end

  # returns the commit time of a commit
  def commit_time(commit_oid = nil)
    get_commit(commit_oid).time unless @repo.empty?
  end

  protected

  def get_commit(commit_oid = nil)
    @repo.lookup(commit_oid || head_oid) unless @repo.empty?
  end
end
