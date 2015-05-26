class CommitReference
  attr_reader :repository, :reference

  def initialize(repository, reference)
    @repository = repository
    @reference = reference
  end

  def commit_oid
    commit.try(:commit_oid)
  end

  def commit
    @commit ||= retrieve_commit_reference
  end

  protected
  def commit_oid?
    !!(reference =~ /\A[a-fA-F0-9]{7,40}\Z/)
  end

  def date?
    !!(reference =~ /\A\d{4}-\d{2}-\d{2}\Z/)
  end

  def branch?
    !! branch_oid
  end

  def retrieve_commit_reference
    with_date_reference ||
      with_commit_reference ||
      with_branch_reference
  end

  def with_date_reference
    if date?
      Commit.where(repository_id: repository).
        where('commits.author_date <= ?', end_of_day(reference)).
        order('commits.author_date DESC').first
    end
  end

  def with_commit_reference
    if commit_oid?
      Commit.where(repository_id: repository).
        where(commit_oid: reference).first
    end
  end

  def with_branch_reference
    Commit.where(repository_id: repository).
      where(commit_oid: branch_oid).first
  end

  def branch_oid
    repository.git.branches.reduce(nil) do |_init, branch|
      return branch[:oid] if reference == branch[:name]
    end
  end

  def end_of_day(date_reference)
    "#{date_reference} 23:59:59"
  end
end
