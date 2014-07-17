module GitRepository::GetFolderContents
  # depends on GitRepository, GetCommit, GetObject
  extend ActiveSupport::Concern

  # returns the contents (files and subfolders) of a folder
  def folder_contents(commit_oid=nil, path='')
    path ||= '/'
    rugged_commit = get_commit(commit_oid)
    if !rugged_commit && path.empty?
      []
    else
      folder_contents_rugged(rugged_commit, path)
    end
  end

  # iterates over all files in the repository, passing the filepath and the oid of the last change to the block
  def files(commit_oid=nil, &block)
    files_recursive('', get_commit(commit_oid), &block)
  end


  protected

  def files_recursive(folder, rugged_commit, &block)
    folder_contents_rugged(rugged_commit, folder).each do |entry|
      case entry.type
      when :dir
        files_recursive(entry.path, rugged_commit, &block)
      when :file
        block.call GitRepository::Files::GitFile.new(self, rugged_commit, entry.path)
      end
    end
  end

  def folder_contents_rugged(rugged_commit, path='')
    path = '' if path == '/' || path.nil?
    return [] unless path_exists_rugged?(rugged_commit, path)

    tree = get_object(rugged_commit, path)
    contents = []

    if tree.type == :tree
      tree.each_tree do |subdir|
        filepath = [path, subdir[:name]].select(&:present?).compact.join('/')
        contents << GitRepository::Files::GitFile.new(self, rugged_commit, filepath)
      end

      tree.each_blob do |file|
        filepath = [path, file[:name]].select(&:present?).compact.join('/')
        contents << GitRepository::Files::GitFile.new(self, rugged_commit, filepath)
      end
    end

    contents
  end
end
