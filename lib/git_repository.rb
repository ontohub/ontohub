# Wrapper for access to the local Git repository
# requires git and git-svn to be installed for the functions clone_git and clone_svn to work
class GitRepository
  require 'git_repository/config'

  include \
    Config,
    Cloning,
    GetCommit,
    GetObject,
    GetDiff,
    GetFolderContents,
    GetInfoList,
    Commit,
    History

  def initialize(path)
    if File.exists?(path)
      @repo = Rugged::Repository.new(path)
    else
      FileUtils.mkdir_p(Ontohub::Application.config.git_root)
      @repo = Rugged::Repository.init_at(path, true)
    end
  end

  # DELETEME (exists only for debugging purpose)
  def repo
    @repo
  end

  def destroy
    FileUtils.rmtree(@repo.path)
  end

  def empty?
    @repo.empty?
  end

  def dir?(path, commit_oid=nil)
    if empty?
      return false
    end

    rugged_commit = repo.lookup(commit_oid || head_oid)
    object = get_object(rugged_commit, path)

    !object.nil? && object.type == :tree
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

  def get_path_of_dir(oid=nil, path=nil)
    path ||= ''
    path = path[0..-2] if(path[-1] == '/')
    raise URLNotFoundError.new unless path_exists?(path, oid)

    path
  end

  def self.directory(path)
    path.split("/")[0..-2].join("/")
  end

  def branches
    @repo.refs.map do |r|
      {
        refname: r.name,
        name: r.name.split('/')[-1],
        oid: r.target
      }
    end
  end

  def branch_oid(name)
    ref = Rugged::Reference.lookup(@repo, "refs/heads/#{name}")

    if ref.nil?
      nil
    else
      ref.target
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
    if @repo.empty?
      nil
    else
      @repo.head.target
    end
  end

  def self.is_repository_with_working_copy?(path)
    repo = Rugged::Repository.new(path)

    !repo.bare?
  rescue Rugged::RepositoryError
    false
  end

  def self.is_bare_repository?(path)
    Rugged::Repository.new(path).bare?
  rescue Rugged::RepositoryError
    false
  end

  def self.mime_type_editable?(mime_type)
    mime_type.to_s == 'application/xml' || mime_type.to_s.match(/^text\/.*/)
  end

  def self.mime_info(filename)
    ext = File.extname(filename)[1..-1]
    mime_type = Mime::Type.lookup_by_extension(ext) || Mime::TEXT
    mime_category = mime_type.to_s.split('/')[0]

    {
      mime_type: mime_type,
      mime_category: mime_category
    }
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
      mime_info = self.class.mime_info(filename)
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

  def head
    @repo.lookup(head_oid)
  end
end
