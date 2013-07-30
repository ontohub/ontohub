# Wrapper for access to the local Git repository
class GitRepository

  include \
    GetCommit,
    GetObject,
    GetDiff,
    GetFolderContents,
    GetInfoList,
    Commit

  def initialize(path)
    if File.exists?(path)
      @repo = Rugged::Repository.new(path)
    else
      @repo = Rugged::Repository.init_at(path, true)
    end
  end

  def destroy
    FileUtils.rmtree(@repo.path)
  end

  def empty?
    @repo.empty?
  end

  def path_exists?(url, commit_oid=nil)
    rugged_commit = get_commit(commit_oid)
    if !rugged_commit && url.empty?
      true
    else
      path_exists_rugged?(rugged_commit, url)
    end
  end

  def get_file(url, commit_oid=nil)
    rugged_commit = get_commit(commit_oid)
    if !rugged_commit && url.empty?
      nil
    else
      get_file_rugged(rugged_commit, url)
    end
  end

  def get_url(oid=nil, url=nil)
    url ||= ''
    url = url[0..-2] if(url[-1] == '/')
    raise URLNotFoundError.new unless path_exists?(url, oid)

    url
  end

  def self.directory(path)
    path.split("/")[0..-2].join("/")
  end

  def get_branches
    @repo.refs.map do |r|
      {
        refname: r.name,
        name: r.name.split('/')[-1],
        oid: r.target
      }
    end
  end

  def build_target_path(url, file_name)
    file_path = url.dup
    file_path << '/' if file_path[-1] != '/' && !file_path.empty?
    file_path << file_name

    file_path
  end

  def is_head?(commit_oid=nil)
    commit_oid == nil || (!@repo.empty? && commit_oid == head_oid)
  end

  def head_oid
    @repo.head.target
  end


  protected

  def path_exists_rugged?(rugged_commit, url='')
    if url.empty?
      true
    else
      tree = rugged_commit.tree
      nil != get_object(rugged_commit, url)
    end
  rescue Rugged::OdbError
    false
  end

  def get_file_rugged(rugged_commit, url='')
    return nil unless path_exists_rugged?(rugged_commit, url)

    object = get_object(rugged_commit, url)

    if object.type == :blob
      filename = url.split('/')[-1]
      mime_info = mime_info(filename)
      {
        name: filename,
        size: object.size,
        content: object.content,
        mime_type: mime_info[:mime_type],
        mime_category: mime_info[:mime_category]
      }
    else
      nil
    end
  end

  def mime_info(filename)
    ext = File.extname(filename)[1..-1]
    mime_type = Mime::Type.lookup_by_extension(ext) || Mime::TEXT
    mime_category = mime_type.to_s.split('/')[0]

    {
      mime_type: mime_type,
      mime_category: mime_category
    }
  end

  def head
    @repo.lookup(head_oid)
  end
end
