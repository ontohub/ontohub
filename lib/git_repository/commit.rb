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

    index = repo.index
    if file_contents.nil?
      index.remove(target_path)
    else
      index.read_tree(repo.head.target.tree) unless repo.empty?
      blob_oid = repo.write(file_contents, :blob)
      index.add(path: target_path, oid: blob_oid, mode: 0100644)
    end

    userinfo[:time] ||= Time.now

    options = {}
    options[:tree] = index.write_tree(repo)

    options[:author] = userinfo
    options[:committer] = userinfo
    options[:message] = message
    options[:parents] = repo.empty? ? [] : [ repo.head.target ].compact
    options[:update_ref] = 'HEAD'

    commit_oid = Rugged::Commit.create(repo, options)

    block.call(commit_oid) if block_given?

    commit_oid
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

end
