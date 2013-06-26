module GitRepository::GetInfoList
  # depends on GitRepository, GetCommit, GetObject, GetFolderContents
  extend ActiveSupport::Concern

  # returns information about the last commit of the files in a folder
  def entries_info(commit_oid=nil, url_folder='')
    rugged_commit = get_commit(commit_oid)
    if !rugged_commit && url_folder.empty?
      []
    else
      contents = folder_contents_rugged(rugged_commit, url_folder)
      contents.map do |e|
        file_path = build_target_path(url_folder, e[:name])
        entry_info_rugged(rugged_commit, file_path)
      end
    end
  end

  # returns information about the last commit of a file
  def entry_info(url, commit_oid=nil)
    rugged_commit = get_commit(commit_oid)
    entry_info_rugged(get_commit(commit_oid), url)
  end

  # returns the information of all commits considering a file (commit history of a file)
  def entry_info_list(url, commit_oid=nil)
    rugged_commit = get_commit(commit_oid)
    if !rugged_commit
      []
    else
      entry_info_list_rugged(rugged_commit, url)
    end
  end


  protected

  def entry_info_rugged(rugged_commit, url)
    object = get_object(rugged_commit, url)
    changing_rugged_commit = get_commit_of_last_change(url, object.oid, rugged_commit)
    build_entry_info(changing_rugged_commit, url)
  end

  def build_entry_info(changing_rugged_commit, url)
    {
      committer_name: changing_rugged_commit.committer[:name],
      committer_email: changing_rugged_commit.committer[:email],
      committer_time: changing_rugged_commit.committer[:time].iso8601,
      message: Commit.message_title(changing_rugged_commit.message),
      oid: changing_rugged_commit.oid,
      filename: url.split('/')[-1]
    }
  end

  def entry_info_list_rugged(rugged_commit, url)
    entries = []

    changing_rugged_commit = get_commit_of_last_change(url, nil, rugged_commit)
    previous_rugged_commit = nil

    until changing_rugged_commit == previous_rugged_commit || !changing_rugged_commit do
      entries << changing_rugged_commit.oid

      previous_rugged_commit = changing_rugged_commit

      unless changing_rugged_commit.parents.empty?
        changing_rugged_commit = get_commit_of_last_change(url, nil, changing_rugged_commit.parents.first)
      end
    end

    # file does not exist in inital commit
    if changing_rugged_commit && !path_exists_rugged?(changing_rugged_commit, url)
      entries[0..-2]
    else
      entries
    end
  end

  def get_commit_of_last_change(url, previous_entry_oid=nil, rugged_commit=nil, previous_rugged_commit=nil)
    rugged_commit ||= head

    object = get_object(rugged_commit, url)
    object_oid = object ? object.oid : nil

    previous_entry_oid ||= object_oid unless previous_rugged_commit

    if object_oid == previous_entry_oid
      if rugged_commit.parents.empty?
        rugged_commit
      else
        parents = rugged_commit.parents.sort_by do |p|
          get_commit_of_last_change(url, previous_entry_oid, p, rugged_commit).committer[:time]
        end
        get_commit_of_last_change(url, previous_entry_oid, parents[-1], rugged_commit)
      end
    else
      previous_rugged_commit
    end
  end
end