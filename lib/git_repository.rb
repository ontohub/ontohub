# Wrapper for access to the local Git repository
# requires git and git-svn to be installed for the functions clone_git and clone_svn to work
class GitRepository
  require 'git_repository/config'

  include \
    Config,
    Cloning,
    Files,
    GetCommit,
    GetObject,
    GetDiff,
    GetFolderContents,
    GetInfoList,
    Commit,
    History

  attr_reader :repo

  delegate :path, :empty?, to: :repo

  def initialize(path)
    if File.exists?(path)
      @repo = Rugged::Repository.new(path)
    else
      FileUtils.mkdir_p(Ontohub::Application.config.git_root)
      @repo = Rugged::Repository.init_at(path, true)
    end
  end

  def destroy
    FileUtils.rmtree(self.path)
  end

  def dir?(path, commit_oid=nil)
    path ||= '/'
    if empty?
      return false
    end

    rugged_commit = repo.lookup(commit_oid || head_oid)
    object = get_object(rugged_commit, path)

    !object.nil? && object.type == :tree
  end

  def path_exists?(path, commit_oid=nil)
    rugged_commit = get_commit(commit_oid)
    if !rugged_commit && path.empty?
      true
    else
      path_exists_rugged?(rugged_commit, path)
    end
  end

  def paths_starting_with(path, commit_oid=nil)
    dir = dir?(path, commit_oid) ? path : path.split('/')[0..-2].join('/')
    contents = folder_contents(commit_oid, dir)

    contents.map { |git_file| git_file.path }.
      select { |p| p.starts_with?(path) }
  end

  def get_file(path, commit_oid=nil)
    begin
      get_file!(path, commit_oid)
    rescue GitRepository::PathNotFoundError
      nil
    end
  end

  def get_file!(path, commit_oid=nil)
    path ||= '/'
    rugged_commit = get_commit(commit_oid)
    raise GitRepository::PathNotFoundError if !rugged_commit && path.empty?

    GitFile.new(self, rugged_commit, path)
  end

  def get_path_of_dir(oid=nil, path=nil)
    path ||= ''
    path = path[0..-2] if(path[-1] == '/')
    raise PathNotFoundError.new unless path_exists?(path, oid)

    path
  end

  def self.directory(path)
    path.split("/")[0..-2].join("/")
  end

  # given a commit oid or a branch name, commit_id returns a hash of oid and branch name if existent
  def commit_id(oid)
    return { oid: head_oid, branch_name: 'master' } if oid.nil?
    if oid.match(/[0-9a-fA-F]{40}/)
      branch_names = branches.select { |b| b[:oid] == oid }
      if branch_names.empty?
        { oid: oid, branch_name: nil }
      else
        { oid: oid, branch_name: branch_names[0][:name] }
      end
    else
      if branch_oid(oid).nil?
        nil
      else
        { oid: branch_oid(oid), branch_name: oid }
      end
    end
  end

  def branches
    repo.refs.map do |ref|
      {
        refname: ref.name,
        name: ref.name.split('/')[-1],
        commit: ref.target,
        oid: ref.target.oid
      }
    end
  end

  def branch_commit(name)
    ref = repo.references["refs/heads/#{name}"]

    if ref.nil?
      nil
    else
      ref.target
    end
  end

  def branch_oid(name)
    if commit = branch_commit(name)
      commit.oid
    end
  end

  def build_target_path(path, file_name)
    file_path = path.dup
    file_path << '/' if file_path[-1] != '/' && !file_path.empty?
    file_path << file_name

    file_path
  end

  def is_head?(commit_oid=nil)
    commit_oid.nil? || (!empty? && commit_oid == head_oid)
  end

  def head_oid
    if empty?
      nil
    else
      repo.head.target.oid
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

  def path_exists_rugged?(rugged_commit, path='/')
    if path.empty?
      true
    else
      nil != get_object(rugged_commit, path)
    end
  rescue Rugged::OdbError
    false
  end

  def head
    repo.lookup(head_oid)
  end
end
