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

  def dir?(path, commit_oid = nil)
    path ||= '/'
    if empty?
      return false
    end

    rugged_commit = repo.lookup(commit_oid || head_oid)
    object = get_object(rugged_commit, path)

    !object.nil? && object.type == :tree
  end

  def path_exists?(path, commit_oid = nil)
    return true if path == '/' || path.empty?
    return false if empty?
    rugged_commit = get_commit(commit_oid)
    if !rugged_commit && path.empty?
      true
    else
      path_exists_rugged?(rugged_commit, path)
    end
  end

  def paths_starting_with(path, commit_oid = nil)
    dir = dir?(path, commit_oid) ? path : path.split('/')[0..-2].join('/')
    contents = folder_contents(commit_oid, dir)

    contents.map { |git_file| git_file.path }.
      select { |p| p.starts_with?(path) }
  end

  def get_file(path, commit_oid = nil)
    begin
      get_file!(path, commit_oid)
    rescue GitRepository::PathNotFoundError
      nil
    end
  end

  def get_file!(path, commit_oid = nil)
    path ||= '/'
    rugged_commit = get_commit(commit_oid)
    raise GitRepository::PathNotFoundError if !rugged_commit && path.empty?

    GitFile.new(self, rugged_commit, path)
  end

  def get_path_of_dir(oid = nil, path = nil)
    path ||= ''
    path = path[0..-2] if(path[-1] == '/')
    raise PathNotFoundError.new unless path_exists?(path, oid)

    path
  end

  def self.directory(path)
    path.split("/")[0..-2].join("/")
  end

  def deepest_existing_dir(path, commit_oid = nil)
    path ||= '/'
    dirs = path.split('/')

    dir = nil
    Array(0..dirs.length - 1).reverse.each do |i|
      if dir.nil?
        path = dirs[0..i].join('/')
        dir = path if dir?(path, commit_oid)
      end
    end

    dir
  end

  # Given a commit oid or a branch name, commit_id returns a hash of oid and
  # branch name if existent.
  def commit_id(ref)
    return {oid: head_oid, branch_name: 'master'} if ref.nil?
    if ref.match(/[0-9a-fA-F]{40}/)
      commit_id_by_oid(ref)
    else
      commit_id_by_branch_name(ref)
    end
  end

  def commit_id_by_oid(oid)
    branch_names = branches_by_oid(oid)
    {oid: oid, branch_name: branch_names.empty? ? nil : branch_names[0][:name]}
  end

  def commit_id_by_branch_name(name)
    if branch_oid(name).nil?
      nil
    else
      {oid: branch_oid(name), branch_name: name}
    end
  end

  def branches_by_oid(oid)
    branches.select { |b| b[:oid] == oid }
  end

  def branches
    repo.refs.map do |ref|
      {
        refname: ref.name,
        name: ref.name.split('/')[-1],
        commit: ref.target,
        oid: ref.target.oid,
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

  def path_exists_rugged?(rugged_commit, path = '/')
    path.empty? || !get_object(rugged_commit, path).nil?
  rescue Rugged::OdbError
    false
  end

  def head
    repo.lookup(head_oid)
  end
end
