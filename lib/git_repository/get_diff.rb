module GitRepository::GetDiff
  # depends on GitRepository
  extend ActiveSupport::Concern

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
    files_contents = []
    files_contents.concat(gcf_subtrees(current_tree, parent_tree, directory))
    files_contents.concat(gcf_current(current_tree, parent_tree, directory))


    files_contents
  end

  def gcf_subtrees(current_tree, parent_tree, directory)
    files_contents = []
    files_contents.concat(gcf_subtrees_addeed_and_changed(current_tree, parent_tree, directory))
    files_contents.concat(gcf_subtrees_deleted(current_tree, parent_tree, directory))

    files_contents
  end

  def gcf_subtrees_addeed_and_changed(current_tree, parent_tree, directory)
    files_contents = []
    current_tree.each do |e|
      if e[:type] == :tree
        if parent_tree[e[:name]] && e[:oid] != parent_tree[e[:name]][:oid]
          files_contents.concat(gcf_complete(@repo.lookup(e[:oid]), @repo.lookup(parent_tree[e[:name]][:oid]), "#{directory}#{e[:name]}/"))
        elsif !parent_tree[e[:name]]
          files_contents.concat(gcf_complete(@repo.lookup(e[:oid]), {}, "#{directory}#{e[:name]}/"))
        elsif parent_tree == {} || parent_tree.count == 0
          files_contents.concat(gcf_complete(@repo.lookup(e[:oid]), parent_tree, "#{directory}#{e[:name]}/"))
        end
      end
    end

    files_contents
  end

  def gcf_subtrees_deleted(current_tree, parent_tree, directory)
    files_contents = []
    parent_tree.each do |e|
      if e[:type] == :tree && !current_tree[e[:name]]
        files_contents.concat(gcf_complete({}, @repo.lookup(e[:oid]), "#{directory}#{e[:name]}/"))
      end
    end

    files_contents
  end

  def gcf_current(current_tree, parent_tree, directory)
    files_contents = []
    files_contents.concat(gcf_current_added_and_changed(current_tree, parent_tree, directory))
    files_contents.concat(gcf_current_deleted(current_tree, parent_tree, directory))

    files_contents
  end

  def gcf_current_added_and_changed(current_tree, parent_tree, directory)
    files_contents = []
    current_tree.each do |e|
      if e[:type] == :blob
        if parent_tree[e[:name]] && e[:oid] != parent_tree[e[:name]][:oid]
          files_contents << changed_files_entry(directory, e[:name], :change, @repo.lookup(e[:oid]).content, @repo.lookup(parent_tree[e[:name]][:oid]).content)
        elsif !parent_tree[e[:name]]
          files_contents << changed_files_entry(directory, e[:name], :add, @repo.lookup(e[:oid]).content, '')
        end
      end
    end

    files_contents
  end

  def gcf_current_deleted(current_tree, parent_tree, directory)
    files_contents = []
    parent_tree.each do |e|
      if e[:type] == :blob && !current_tree[e[:name]]
        files_contents << changed_files_entry(directory, e[:name], :delete, '', '')
      end
    end

    files_contents
  end

  def changed_files_entry(directory, name, type, content_current, content_parent)
    mime_info = mime_info(name)
    editable = mime_type_editable?(mime_info[:mime_type])
    {
      name: name,
      path: "#{directory}#{name}",
      diff: editable ? diff(content_current, content_parent) : '',
      type: type,
      mime_type: mime_info[:mime_type],
      mime_category: mime_info[:mime_category],
      editable: editable
    }
  end


  def diff(current, original)
    Diffy::Diff.new(original.force_encoding('UTF-8'), current.force_encoding('UTF-8'), include_plus_and_minus_in_html: true, context: 3, include_diff_info: true).to_s(:html)
  end

  def mime_type_editable?(mime_type)
    mime_type.to_s == 'application/xml' || mime_type.to_s.match(/^text\/.*/)
  end
end
