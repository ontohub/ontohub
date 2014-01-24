module GitRepository::GetDiff
  # depends on GitRepository
  extend ActiveSupport::Concern

  # Represents a added/changed/deleted file
  class FileChange
    attr_accessor :directory, :name, :oid, :parent_oid, :type

    def initialize(repo, directory, name, type, oid=nil, parent_oid=nil)
      @repo       = repo
      @directory  = directory
      @name       = name
      @type       = type
      @oid        = oid
      @parent_oid = parent_oid
    end

    %w( add change delete ).each do |type|
      class_eval "def #{type}?; @type==:#{type}; end"
    end

    def path
      "#{directory}#{name}"
    end

    def content
      @repo.lookup(oid).content
    end

    def content_parent
      @repo.lookup(parent_oid).content
    end

    def mime_info
      @mime_info ||= GitRepository.mime_info(name)
    end

    def mime_type
      mime_info[:mime_type]
    end

    def mime_category
      mime_info[:mime_category]
    end

    def editable?
      GitRepository.mime_type_editable?(mime_type)
    end

    def diff
      @repo.diff(content, content_parent)
    end
  end

  # returns a list of files changed by a commit
  def changed_files(commit_oid=nil)
    rugged_commit = get_commit(commit_oid)
    if !rugged_commit
      []
    else
      gcf_rugged(rugged_commit)
    end
  end


  protected

  def gcf_rugged(rugged_commit)
    if rugged_commit.parents.empty?
      gcf_complete(rugged_commit.tree, {})
    else
      changed_files_infos = rugged_commit.parents.map do |p|
        gcf_complete(rugged_commit.tree, p.tree)
      end

      changed_files_infos.flatten
    end
  end

  def gcf_complete(current_tree, parent_tree, directory='')
    result = []
    result.concat(gcf_subtrees(current_tree, parent_tree, directory))
    result.concat(gcf_current(current_tree, parent_tree, directory))
    result
  end

  def gcf_subtrees(current_tree, parent_tree, directory)
    result = []
    result.concat(gcf_subtrees_addeed_and_changed(current_tree, parent_tree, directory))
    result.concat(gcf_subtrees_deleted(current_tree, parent_tree, directory))
    result
  end

  def gcf_subtrees_addeed_and_changed(current_tree, parent_tree, directory)
    result = []
    current_tree.each do |e|
      if e[:type] == :tree
        if parent_tree[e[:name]] && e[:oid] != parent_tree[e[:name]][:oid]
          result.concat(gcf_complete(@repo.lookup(e[:oid]), @repo.lookup(parent_tree[e[:name]][:oid]), "#{directory}#{e[:name]}/"))
        elsif !parent_tree[e[:name]]
          result.concat(gcf_complete(@repo.lookup(e[:oid]), {}, "#{directory}#{e[:name]}/"))
        elsif parent_tree == {} || parent_tree.count == 0
          result.concat(gcf_complete(@repo.lookup(e[:oid]), parent_tree, "#{directory}#{e[:name]}/"))
        end
      end
    end

    result
  end

  def gcf_subtrees_deleted(current_tree, parent_tree, directory)
    result = []
    parent_tree.each do |e|
      if e[:type] == :tree && !current_tree[e[:name]]
        result.concat(gcf_complete({}, @repo.lookup(e[:oid]), "#{directory}#{e[:name]}/"))
      end
    end

    result
  end

  def gcf_current(current_tree, parent_tree, directory)
    result = []
    result.concat(gcf_current_added_and_changed(current_tree, parent_tree, directory))
    result.concat(gcf_current_deleted(current_tree, parent_tree, directory))
    result
  end

  def gcf_current_added_and_changed(current_tree, parent_tree, directory)
    result = []
    current_tree.each do |e|
      if e[:type] == :blob
        if parent_tree[e[:name]] && e[:oid] != parent_tree[e[:name]][:oid]
          result << changed_files_entry(directory, e[:name], :change, e[:oid], parent_tree[e[:name]][:oid])
        elsif !parent_tree[e[:name]]
          result << changed_files_entry(directory, e[:name], :add, e[:oid])
        end
      end
    end

    result
  end

  def gcf_current_deleted(current_tree, parent_tree, directory)
    result = []
    parent_tree.each do |e|
      if e[:type] == :blob && !current_tree[e[:name]]
        result << changed_files_entry(directory, e[:name], :delete)
      end
    end

    result
  end

  def changed_files_entry(*args)
    FileChange.new(self, *args)
  end

  def diff(current, previous)
    Diffy::Diff.new(previous.force_encoding('UTF-8'), current.force_encoding('UTF-8'), include_plus_and_minus_in_html: true, context: 3, include_diff_info: true).to_s(:html)
  end

end
