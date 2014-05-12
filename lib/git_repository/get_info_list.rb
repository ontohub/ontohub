module GitRepository::GetInfoList
  # depends on GitRepository, GetCommit, GetObject, GetFolderContents
  extend ActiveSupport::Concern

  # returns information about the last commit of the files in a folder
  def entries_info(commit_oid=nil, path_folder='')
    rugged_commit = get_commit(commit_oid)
    if !rugged_commit && path_folder.empty?
      []
    else
      contents = folder_contents_rugged(rugged_commit, path_folder)
      contents.map do |e|
        file_path = build_target_path(path_folder, e[:name])
        entry_info_rugged(rugged_commit, file_path)
      end
    end
  end

  # returns information about the last commit of a file
  def entry_info(path, commit_oid=nil)
    rugged_commit = get_commit(commit_oid)
    entry_info_rugged(rugged_commit, path)
  end

  # returns the information of all commits considering a file (commit history of a file)
  def entry_info_list(path, commit_oid=nil)
    rugged_commit = get_commit(commit_oid)
    if !rugged_commit
      []
    else
      entry_info_list_rugged(rugged_commit, path)
    end
  end


  protected

  def commit_message_title(message)
    message.split("\n").first
  end

  def entry_info_rugged(rugged_commit, path)
    changing_rugged_commit = get_commit_of_last_change(path, rugged_commit)
    build_entry_info(changing_rugged_commit, path)
  end

  def build_entry_info(changing_rugged_commit, path)
    {
      committer_name: changing_rugged_commit.committer[:name],
      committer_email: changing_rugged_commit.committer[:email],
      committer_time: changing_rugged_commit.committer[:time].iso8601,
      message: commit_message_title(changing_rugged_commit.message),
      oid: changing_rugged_commit.oid,
      filename: path.split('/')[-1]
    }
  end

  def entry_info_list_rugged(rugged_commit, path)
    entries = []

    changing_rugged_commit = get_commit_of_last_change(path, rugged_commit)
    previous_rugged_commit = nil

    until changing_rugged_commit == previous_rugged_commit || !changing_rugged_commit do
      entries << changing_rugged_commit.oid

      previous_rugged_commit = changing_rugged_commit

      unless changing_rugged_commit.parents.empty?
        changing_rugged_commit = get_commit_of_last_change(path, changing_rugged_commit.parents.first)
      end
    end

    # file does not exist in inital commit
    if changing_rugged_commit && !path_exists_rugged?(changing_rugged_commit, path)
      entries[0..-2]
    else
      entries
    end
  end

  def get_commit_of_last_change(path, rugged_commit=nil)
    rugged_commit ||= head
    object          = get_object(rugged_commit, path)

    while (parent = rugged_commit.parents[-1]) && get_object(parent, path) == object do
      rugged_commit = parent
    end

    rugged_commit
  end
end
