module GitRepository::History
  # depends on GitRepository
  extend ActiveSupport::Concern

  class Commit
    attr_accessor :oid, :message, :committer, :author

    def initialize(commit, commits_to_diff: nil, path: nil)
      @rugged_commit   = commit
      @oid             = commit.oid
      @message         = commit.message
      @committer       = commit.committer
      @author          = commit.author
      @commits_to_diff = commits_to_diff ? commits_to_diff : commit.parents
      @path            = path
    end

    # Diff against _all_ parents
    def combined_diff
      @combined_diff ||= if @commits_to_diff.present?
        @commits_to_diff.map do |parent|
          parent.diff(@rugged_commit)
        end.inject do |diff_merged, parent_diff|
          diff_merged.merge!(parent_diff)
        end.find_similar!
      else
        diff_of_first_commit
      end
    end

    def deltas
      @deltas ||= combined_diff.each_delta.select do |d|
        !@path ||
          [d.old_file[:path], d.new_file[:path]].any?{ |p| p.start_with?(@path) }
      end
    end

    protected
    def diff_of_first_commit
      @rugged_commit.diff(nil, reverse: true)
    end
  end

  # recognized options: :start_oid (first commit to show)
  #                     :stop_oid (first commit to hide)
  #                     :path (file to show changes for)
  #                     :limit (max number of commits)
  #                     :offset (number of commits to skip)
  #                     :walk_order (Rugged-Walkorder)
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
    Rails.logger.warn ""
    Rails.logger.warn ""
    Rails.logger.warn "path: #{path.inspect}"
    Rails.logger.warn "previous_oid: #{previous_oid.inspect}"
    current_oid ||= head_oid
    Rails.logger.warn "current_oid:  #{current_oid.inspect}"

    previous_obj = get_object(repo.lookup(previous_oid), path.to_s)
    current_obj  = get_object(repo.lookup(current_oid),  path.to_s)

    Rails.logger.warn ""
    Rails.logger.warn ""
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

      if block_given?
        commits << block.call(Commit.new(c))
      else
        commits << Commit.new(c)
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
        commit_obj = Commit.new(commit, path: path)

        if commit_obj.deltas.present?
          if offset > 0
            offset = offset - 1
          else
            if block_given?
              commits << block.call(commit_obj)
            else
              commits << to_hash(commit_obj)
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
        commit_obj = Commit.new(commit, path: path)
        if block_given?
          commits << block.call(commit_obj)
        else
          commits << to_hash(commit_obj)
        end
      end
    end

    commits
  rescue Rugged::OdbError #FIXME: returns empty array if repository is cloned in a shallow way
    commits
  end
end
