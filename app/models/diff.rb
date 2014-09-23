class Diff < FakeRecord
  attr_reader :repository, :oid, :changed_files, :commit

  def self.find(opts)
    new(opts)
  end

  def initialize(opts)
    @repository = Repository.find_by_path(opts[:repository_id])
    @commit_id = compute_ref(repository, opts[:ref])

    @oid = @commit_id[:oid]

    @changed_files = repository.changed_files(oid)
    @diff = repository.git.diff(oid)
  end

  def compute
    if !@computed && @diff != :diff_too_large
      raw_diffs = @diff.split('diff --git a/')[1..-1]

      changed_files.each do |file_change|
        diff = raw_diffs.select { |d| d.start_with?(file_change.old_path) }.first
        file_change.diff = diff_without_metadata(diff, file_change.status)
      end
      @computed = true
    end

    @computed
  end

  protected

  def compute_ref(repository, ref)
    repository.commit_id(ref || Settings.git.default_branch)
  end

  def diff_without_metadata(diff, status)
    diff.split("\n", metadata_line_count(status)).last[0..-1]
  end

  def metadata_line_count(status)
    case status
    when :added
      6
    when :deleted
      6
    when :modified
      5
    when :renamed
      5
    end
  end
end
