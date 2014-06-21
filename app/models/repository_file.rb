class RepositoryFile

  class PathValidator < ActiveModel::Validator
    def validate(record)
      if record.repository.points_through_file?(record.target_path)
        record.errors[:target_directory] = "Error! This path points to or through a file."
      end
    end
  end

  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  DEFAULT_BRANCH = 'master'

  # basic repository file usage
  attr_reader :repository, :file
  attr_accessor :index
  delegate :name, :path, :size, :mime_type, :mime_category,
    :oid, :file?, :dir?, :type, to: :file

  # only for new/edit
  attr_reader :message, :temp_file, :target_directory, :target_filename
  validates :message, :temp_file, presence: true
  validates_with PathValidator, :if => :temp_file_exists?

  def self.find_with_path(opts)
    begin
      new(opts)
    rescue GitRepository::PathNotFoundError
      nil
    end
  end

  def self.find_with_path!(opts)
    self.find_with_path(opts) ||
      raise(GitRepository::PathNotFoundError,
        [opts[:repository_id], opts[:ref], opts[:path]].compact.join('/'))
  end

  def self.find_with_basepath(opts)
    repository = Repository.find_by_path(opts[:repository_id])
    oid        = compute_ref(repository, opts[:ref])[:oid]

    dir_path = opts[:path].split('/')[0..-2].join('/')

    entries = repository.git.folder_contents(oid, dir_path).select do |entry|
      entry.path.start_with?(opts[:path]) && entry.file?
    end.map do |entry|
      new(repository_id: repository.to_param, path: entry.path)
    end
  end

  def self.build(opts={})
    if opts[:content] # edit text of file
      tempfile = Tempfile.new('repository_tempfile')
      tempfile.write(opts[:content])
      tempfile.close
      opts.merge!({ temp_file: tempfile })
      new(opts)
    elsif(opts[:repository_file]) # upload file
      new(opts[:repository_file].merge({repository_id: opts[:repository_id]}))
    else
      new(opts)
    end
  end

  def self.create(opts={})
    rf = build(opts)
    if rf.valid?
      rf.repository.save_file(rf.temp_file.path, rf.target_path, rf.message, opts[:user])
    end

    return rf
  end

  def initialize(opts)
    opts = opts.symbolize_keys
    if self.class.manipulating_file?(opts)
      @repository = Repository.find_by_path(opts[:repository_id])
      @message    = opts[:message]
      @temp_file  = opts[:temp_file]
      if opts[:path].present?
        @target_directory = opts[:path].split('/')[0..-2].join('/')
        @target_filename  = opts[:path].split('/')[-1]
      else
        @target_directory = opts[:target_directory]
        @target_filename  = opts[:target_filename]
      end
    elsif opts[:git_file] && opts[:repository]
      @repository = opts[:repository]
      @file       = opts[:git_file]
      @commit_id  = repository.commit_id(file.oid)
    else
      @repository = Repository.find_by_path(opts[:repository_id])
      @commit_id  = repository.commit_id(opts[:ref] || DEFAULT_BRANCH)
      @file       = repository.git.get_file!(opts[:path] || '/', commit_id[:oid])
    end
  end

  def ontologies(child_name=nil)
    if file?
      @ontologies ||= begin
        ontos = repository.ontologies.find_with_path(path).parents_first
        if child_name
          ontos.map!{ |o| o.children.where(name: child_name) }.flatten!
        end

        ontos
      end
    end
  end

  def content
    @content ||= begin
      cntnt = file.content
      if dir?
        cntnt.map! do |e|
          self.class.new(repository: self.repository, git_file: e)
        end
      end

      cntnt
    end
  end

  def to_s
    name
  end

  def to_param
    path
  end

  # Needed for a Model
  def persisted?
    false
  end

  def grouped_entries
    grouped ||= begin
      content.each_with_index do |v,i|
        v.index = i
      end

      Hash[content.group_by do | e |
        { type: e.type, name: basename(e.name) }
      end.map do | k, v |
        [k[:name], v]
      end]
    end
  end

  def basename(name)
    name.split('.')[0..-2].join('.')
  end


  # only for new/edit
  def target_path
    @target_directory ||= ''
    str  = target_directory
    str  = str[1,-1] if target_directory.starts_with?("/")
    str  = str[0,-2] if target_directory.ends_with?("/")
    str += "/" unless target_directory.empty?
    str += target_filename.present? ? target_filename : temp_file.original_filename
  end

  def temp_file_exists?
    temp_file.present?
  end

  protected

  attr_reader :commit_id

  def self.compute_ref(repository, ref)
    repository.commit_id(ref || DEFAULT_BRANCH)
  end

  def self.manipulating_file?(opts)
    opts[:temp_file].present?
  end

end

