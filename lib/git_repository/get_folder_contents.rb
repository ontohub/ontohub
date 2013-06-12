module GitRepository::GetFolderContents
  # depends on GitRepository, GetCommit, GetObject
  extend ActiveSupport::Concern

  def folder_contents(commit_oid=nil, url='')
    rugged_commit = get_commit(commit_oid)
    if !rugged_commit && url.empty?
      []
    else
      folder_contents_rugged(rugged_commit, url)
    end
  end


  protected

  def folder_contents_rugged(rugged_commit, url='')
    return [] unless path_exists_rugged?(rugged_commit, url)

    tree = get_object(rugged_commit, url)
    contents = []

    if tree.type == :tree
      tree.each_tree do |subdir|
        contents << folder_contents_entry(contents, url, :dir, subdir[:name])
      end

      tree.each_blob do |file|
        contents << folder_contents_entry(contents, url, :file, file[:name])
      end
    end

    contents
  end

  def folder_contents_entry(contents, url, type, name)
    path_file = url.dup
    path_file << '/' unless url.empty?
    path_file << name

    {
      type: type,
      name: name,
      path: path_file
    }
  end
end
