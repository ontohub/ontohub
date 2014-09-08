class HistoryEntriesPage
  PER_PAGE = 25

  attr_reader :repository, :oid, :path, :current_file, :commits

  def self.find(opts)
    begin
      new(opts)
    rescue GitRepository::PathNotFoundError
      nil
    end
  end

  def initialize(opts)
    @repository   = Repository.find_by_path(opts[:repository_id])

    @commit_id    = self.class.compute_ref(repository, opts[:ref])
    @oid          = commit_id[:oid]

    @path         = opts[:path]
    @current_file = repository.get_file(path, oid) if path && !repository.dir?(path)

    @page         = opts[:page].nil? ? 1 : opts[:page].to_i
    @offset       = page > 0 ? (page - 1) * PER_PAGE : 0

    @commits      = repository.commits(start_oid: oid, path: path, offset: offset, limit: PER_PAGE)
  end

  def grouped_commits
    @grouped_commits ||= commits.group_by do |c|
      c.committer[:time].strftime("%d.%m.%Y")
    end.map do |k, v|
      {commits: v, date: k}
    end
  end

  def paginated_array
    Kaminari.paginate_array(commits, total_count: ensure_next_page_exists).page(page).per(PER_PAGE)
  end

  protected

  attr_reader :commit_id, :page, :offset

  def self.compute_ref(repository, ref)
    repository.commit_id(ref || DEFAULT_BRANCH)
  end

  def ensure_next_page_exists
    page * (PER_PAGE + 1)
  end

end

