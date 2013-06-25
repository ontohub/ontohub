module GitRepository::GetCommit
  # depends on GitRepository
  extend ActiveSupport::Concern

  def get_commit_message(commit_oid = nil)
    get_commit(commit_oid).message unless @repo.empty?
  end

  def get_commit_author(commit_oid = nil)
    get_commit(commit_oid).author unless @repo.empty?
  end

  def get_commit_time(commit_oid = nil)
    get_commit(commit_oid).time unless @repo.empty?
  end

  protected

  def get_commit(commit_oid = nil)
    @repo.lookup(commit_oid || head_oid) unless @repo.empty?
  end
end
