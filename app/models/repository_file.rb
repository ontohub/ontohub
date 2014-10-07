class RepositoryFile < FakeRecord
  class PathValidator < ActiveModel::Validator
    def validate(record)
      if record.repository.points_through_file?(record.target_path)
        record.errors[:target_directory] = "Error! This path points to or through a file."
      end
    end
  end

  # basic repository file usage
  attr_reader :repository, :file, :user
  attr_accessor :index
  delegate :name, :path, :size, :mime_type, :mime_category,
    :oid, :file?, :dir?, :type, to: :file

  # only for new/edit
  attr_reader :message, :temp_file, :target_directory, :target_filename
  validates :message, :temp_file, presence: true
  validates_with PathValidator, :if => :temp_file_exists?

  def self.find_with_path(opts)
    new(opts)
  rescue GitRepository::PathNotFoundError
    nil
  end

  def self.find_with_path!(opts)
    self.find_with_path(opts) ||
      raise(GitRepository::PathNotFoundError,
        [opts[:repository_id], opts[:ref], opts[:path]].compact.join('/'))
  end

  def self.find_with_basepath(opts)
    repository = Repository.find_by_path(opts[:repository_id])
    oid        = compute_ref(repository, opts[:ref])[:oid]
    dir_path   = opts[:path].split('/')[0..-2].join('/')

    entries = repository.git.folder_contents(oid, dir_path).reduce([]) do |es, entry|
      if entry.path.start_with?(opts[:path]) && entry.file?
        es << new(repository_id: repository.to_param, path: entry.path)
      end
    end
  end

  def initialize(*args, &block)
    opts = args.shift.symbolize_keys
    @user = opts[:user]
    if self.class.manipulating_file?(opts)
      initialize_for_create_and_update(opts)
    elsif opts[:git_file] && opts[:repository]
      initialize_for_already_loaded_file(opts)
    else
      initialize_for_read(opts)
    end
  end

  def save!
    raise RecordNotSavedError unless valid?
    repository.save_file(temp_file.path, target_path, message, user)
  end

  def ontologies(child_name=nil)
    @ontologies ||= if file?
      ontos = repository.ontologies.with_path(path).parents_first
      ontos.map!{ |o| o.children.where(name: child_name) }.flatten! if child_name
      ontos
    end
  end

  def content
    @content ||= if dir?
      file.content.map do |git_file|
        self.class.new(repository: self.repository, git_file: git_file)
      end
    else
      file.content
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

  def grouped_content
    return @grouped unless @grouped.nil?
    ungrouped = content.each_with_index { |entry,i| entry.index = i }
    intermediate_grouped = ungrouped.group_by { |e| {type: e.type, name: basename(e.name)} }
    @grouped = intermediate_grouped.reduce({}) do |hash, (key, value)|
      hash[key] = value
      hash
    end
  end

  def basename(name)
    if name.length > 0 && name[1..-1].include?('.')
      name.split('.')[0..-2].join('.')
    else
      name
    end
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

  def self.manipulating_file?(opts)
    uploading_file?(opts) || editing_file?(opts)
  end

  def self.uploading_file?(opts)
    opts[:repository_file].present?
  end

  def self.editing_file?(opts)
    opts[:path].present? && (opts[:content].present? || opts[:temp_file].present?)
  end

  def initialize_for_read(opts)
    @repository = Repository.find_by_path(opts[:repository_id])
    commit_id   = repository.commit_id(opts[:ref] || Settings.git.default_branch)
    commit_id   = {oid: nil} if repository.empty?
    @file       = repository.git.get_file!(opts[:path] || '/', commit_id[:oid])
  end

  def initialize_for_create_and_update(opts)
    @repository = Repository.find_by_path(opts[:repository_id])

    opts = prepare_opts_on_file_upload(opts)

    @message = opts[:message]

    if self.class.editing_file?(opts)
      opts = prepare_opts_add_tempfile(opts)

      @target_directory = opts[:path].split('/')[0..-2].join('/')
      @target_filename  = opts[:path].split('/')[-1]
    else
      @target_directory = opts[:target_directory]
      @target_filename  = opts[:target_filename]
    end
    @temp_file  = opts[:temp_file]
  end

  def initialize_for_already_loaded_file(opts)
    @repository = opts[:repository]
    @file       = opts[:git_file]
  end

  def editing_file_providing_content?(opts)
    opts[:content].present?
  end

  def prepare_opts_add_tempfile(opts)
    tempfile = Tempfile.new('repository_tempfile')
    tempfile.write(opts[:content])
    tempfile.close

    opts[:temp_file] = tempfile

    opts
  end

  def prepare_opts_on_file_upload(opts)
    if self.class.uploading_file?(opts)
      opts.merge!(opts[:repository_file])
    end

    opts.symbolize_keys
  end

end

