module GitRepository::Commit
  # depends on GitRepository
  extend ActiveSupport::Concern

  # delete a single file and commit the change
  def delete_file(userinfo, target_path, &block)
    commit_file(userinfo, nil, target_path, "Delete file #{target_path}", &block)
  end

  # add a single file and commit the change
  def add_file(userinfo, tmp_path, target_path, message, &block)
    commit_file(userinfo, File.open(tmp_path, 'rb').read, target_path, message, &block)
  end

  # change a single file and commit the change
  def commit_file(userinfo, file_contents, target_path, message, &block)
    # throw exception if path is below a file
    raise GitRepository::PathBelowFileException if points_through_file?(target_path)

    # save current head oid in case of an emergency
    old_head = head_oid unless @repo.empty?

    # Entry
    entry = nil
    if file_contents
      entry = {
        type: :blob,
        name: nil,
        oid: @repo.write(file_contents, :blob),
        content: file_contents,
        filemode: 0100644
      }
    end

    # TreeBuilder
    old_tree = @repo.empty? ? nil : head.tree
    tree     = build_tree(entry, old_tree, target_path.split('/'))

    userinfo[:time] ||= Time.now

    # Commit Sha
    commit_oid = Rugged::Commit.create @repo,
      author:    userinfo,
      message:   message,
      committer: userinfo,
      parents:   commit_parents,
      tree:      tree

    rugged_commit = @repo.lookup(commit_oid)

    if @repo.empty?
      ref = Rugged::Reference.create(@repo, 'refs/heads/master', commit_oid)
    else
      @repo.head.set_target commit_oid
    end

    block.call(commit_oid) if block_given?

    commit_oid
=begin
  rescue => e
    if old_head
      @repo.head.set_target old_head
    else
      @repo.head.delete!
    end

    raise e
=end
  end

  # true for "file.txt/foo"
  # iff "file.txt" is a file in the repository
  def points_through_file?(target_path)
    return false if empty?
    return false unless target_path

    parts = target_path.split('/')

    rugged_commit = @repo.lookup(head_oid)
    object = get_object(rugged_commit, parts[0..-2].join('/'))

    !object.nil? && object.type == :blob
  rescue NoMethodError => e
    if e.message.match(/undefined method.`\[\]'/) &&
        e.message.match(/Rugged..Blob./)
      true
    else
      raise e
    end
  end


  protected

  def build_tree(entry, tree, path_parts)
    builder = Rugged::Tree::Builder.new

    if tree
      old_entry = nil

      tree.each do |e|
        builder.insert(e)
        old_entry = e if e[:name] == path_parts.first
      end

      if old_entry
        if old_entry[:type] == :tree
          bt_tree(builder, entry, @repo.lookup(old_entry[:oid]), path_parts)
        else
          bt_blob(builder, entry, path_parts)
        end
      else
        if path_parts.size == 1
          bt_blob(builder, entry, path_parts)
        else
          bt_tree(builder, entry, nil, path_parts)
        end
      end

    elsif path_parts.size == 1
      bt_blob(builder, entry, path_parts)
    else
      bt_tree(builder, entry, nil, path_parts)
    end
    builder.reject! do |e|
      e[:type] == :tree && @repo.lookup(e[:oid]).count == 0
    end
    tree_oid = builder.write(@repo)

    @repo.lookup(tree_oid)
  end

  def bt_tree(builder, entry, old_entry, path_parts)
    new_tree = build_tree(entry, old_entry, path_parts[1..-1])
    tree_entry = {
      type: :tree,
      name: path_parts.first,
      oid: new_tree.oid,
      filemode: 16384
    }
    builder.insert(tree_entry)
  end

  def bt_blob(builder, entry, path_parts)
    if entry
      entry[:name] = path_parts.first
      builder.insert(entry)
    else
      builder.reject! { |e| e[:name] == path_parts.first }
    end
  end

  def commit_parents
    if @repo.empty?
      []
    else
      [head_oid]
    end
  end

  def get_parents(rugged_commit)
    if rugged_commit.parents.empty?
      []
    else
      commits.identifiers(rugged_commit.parents.map { |c| c.oid }, self)
    end
  end
end
