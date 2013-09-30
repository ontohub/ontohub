module GitRepository::History
  # depends on GitRepository
  extend ActiveSupport::Concern

  def commits(oid=nil, path=nil)
    oid ||= head_oid
    walker = Rugged::Walker.new(@repo)
    walker.push(oid)

    if path.nil?
      commits_all(walker)
    else
      commits_path(walker, path)
    end
  end


  protected

  def commits_all(walker)
    commits = []
    walker.each do |c|
      commits << to_hash(c)
    end

    commits
  rescue Rugged::OdbError #FIXME: returns empty array if repository is cloned in a shallow way
    commits
  end

  def commits_path(walker, path)
    commits = []

    object = nil
    commit = nil

    walker.each do | previous_commit |
      previous_object = get_object(previous_commit, path)

      if object_added(object, previous_object, !commit.nil?) || 
      object_changed(object, previous_object, !commit.nil?) || 
      object_deleted(object, previous_object, !commit.nil?)
        commits << to_hash(commit)
      end

      object = previous_object
      commit = previous_commit
    end

    unless object.nil?
      commits << to_hash(commit)
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
