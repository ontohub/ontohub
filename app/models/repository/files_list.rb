module Repository::FilesList
  extend ActiveSupport::Concern

  def list_folder(folderpath, commit_oid=nil)
    folderpath ||= '/'
    contents = git.folder_contents(commit_oid, folderpath).each_with_index do |v,i|
      v[:index] = i
    end

    grouped = Hash[contents.group_by do | e |
      { type: e[:type], name: basename(e[:name]) }
    end.map do | k, v |
      [k[:name], v]
    end]

    grouped
  end

  def basename(name)
    name.split('.')[0]
  end
end
