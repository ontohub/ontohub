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

      if block_given?
        commits << block.call(c.oid)
      else
        commits << to_hash(c)
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

    added_commits = 0

    walker.each do |previous_commit|
      break if limit && added_commits == limit
      previous_object = get_object(previous_commit, path)

      if object_added(object, previous_object, !commit.nil?) ||
         object_changed(object, previous_object, !commit.nil?) ||
         object_deleted(object, previous_object, !commit.nil?)

        if offset > 0
          offset = offset - 1
        else
          if block_given?
            commits << block.call(commit.oid)
          else
            commits << to_hash(commit)
          end
          added_commits = added_commits + 1
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
          commits << to_hash(commit)
        end
      end
    end

    commits
  rescue Rugged::OdbError #FIXME: returns empty array if repository is cloned in a shallow way
    commits
  end

  def to_hash(commit)
    {
      message: commit.message,
      committer: commit.committer,
      author: commit.author,
      oid: commit.oid
    }
  end

  def object_changed(object, previous_object, started)
    started && !object.nil? && !previous_object.nil? && object.oid != previous_object.oid
  end

  def object_added(object, previous_object, started)
    started && !object.nil? &&  previous_object.nil?
  end

  def object_deleted(object, previous_object, started)
    started &&  object.nil? && !previous_object.nil?
  end
end
