module GitRepository::GetFolderContents
  # depends on GitRepository, GetCommit, GetObject
  extend ActiveSupport::Concern

  # File entry
  Entry = Struct.new(:git, :commit_oid, :type, :name, :path) do
    def initialize(git, commit_oid, entry)
      self.git        = git
      self.commit_oid = commit_oid
      entry.each do |key,val|
        self[key] = val
      end
    end

    def last_change
      @last_change ||= git.entry_info(path, commit_oid)
    end
  end

  # returns the contents (files and subfolders) of a folder
  def folder_contents(commit_oid=nil, url='')
    rugged_commit = get_commit(commit_oid)
    if !rugged_commit && url.empty?
      []
    else
      folder_contents_rugged(rugged_commit, url)
    end
  end

  # iterates over all files in the repository, passing the filepath and the oid of the last change to the block
  def files(commit_oid=nil, &block)
    files_recursive('', commit_oid, &block)
  end


  protected

  def files_recursive(folder, commit_oid=nil, &block)
    folder_contents(commit_oid, folder).each do |entry|
      case entry[:type]
      when :dir
        files_recursive(entry[:path], commit_oid, &block)
      when :file
        block.call Entry.new(self, commit_oid, entry)
      end
    end
  end

  def folder_contents_rugged(rugged_commit, url='')
    url = '' if url == '/' || url.nil?
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
