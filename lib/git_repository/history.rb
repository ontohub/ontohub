module GitRepository::History
  # depends on GitRepository
  extend ActiveSupport::Concern

  def commits(start_oid: nil, stop_oid: nil, path: nil, limit: nil, offset: 0, walk_order: nil, &block)
    return [] if @repo.empty?
    start_oid ||= head_oid
    offset = 0 if offset < 0
    stop_oid = nil if stop_oid =~ /\A0+\z/

    walker = Rugged::Walker.new(@repo)
    walker.sorting(walk_order) if walk_order
    walker.push(start_oid)
    walker.hide(stop_oid) if stop_oid

    if path
      commits_path(walker, limit, offset, path, &block)
    else
      commits_all(walker, limit, offset, &block)
    end
  end

  # check if the file at path has changed between previous_oid and current_oid
  def has_changed?(path, previous_oid, current_oid=nil)
    current_oid ||= head_oid

    previous_obj = get_object(repo.lookup(previous_oid), path)
    current_obj  = get_object(repo.lookup(current_oid),  path)

    if previous_obj.nil? || current_obj.nil?
      true
    else
      previous_obj.oid != current_obj.oid
    end
  end

  protected

  def commits_all(walker, limit, offset, &block)
    commits = []
    offset_original = offset

    walker.each_with_index do |c,i|
      if offset > 0
        offset = offset - 1
        next
      end

      break if limit && i-offset_original == limit

      deltas = retrieve_deltas(c.parents, c)

      if block_given?
        commits << block.call(c.oid, deltas)
      else
        commits << to_hash(c, deltas)
      end
    end

    commits
  rescue Rugged::OdbError #FIXME: returns empty array if repository is cloned in a shallow way
    commits
  end

  def commits_path(walker, limit, offset, path, &block)
    commits = []

    object = nil
    commit = nil
    deltas = nil

    added_commits = 0

    walker.each do |previous_commit|
      break if limit && added_commits == limit
      previous_object = get_object(previous_commit, path)

      if commit
        deltas = retrieve_deltas([previous_commit], commit, path)

        if deltas.present?
          if offset > 0
            offset = offset - 1
          else
            if block_given?
              commits << block.call(commit.oid, deltas)
            else
              commits << to_hash(commit, deltas)
            end
            added_commits = added_commits + 1
          end
        end
      end

      object = previous_object
      commit = previous_commit
    end

    unless object.nil?
      unless limit && added_commits == limit
        if block_given?
          commits << block.call(commit.oid)
        else
          commits << to_hash(commit, deltas)
        end
      end
    end

    commits
  rescue Rugged::OdbError #FIXME: returns empty array if repository is cloned in a shallow way
    commits
  end

  def to_hash(commit, deltas)
    {
      message: commit.message,
      committer: commit.committer,
      author: commit.author,
      oid: commit.oid,
      deltas: deltas
    }
  end

  def combined_diff(parent_commits, current_commit)
    parent_commits.map do |parent|
      parent.diff(current_commit)
    end.inject do |diff_merged, parent_diff|
      diff_merged.merge!(parent_diff)
    end.find_similar!
  end

  def retrieve_deltas(parent_commits, current_commit, path='')
    combined_diff(parent_commits, current_commit)
      .each_delta.select do |d|
      d.old_file[:path].start_with?(path) || d.new_file[:path].start_with?(path)
    end
  end
end
