# RepositoryDirectory is only used for the creation of directories,
# and NOT for information retrieval like directory listing.
# For the latter, see RepositoryFile.
class RepositoryDirectory < FakeRecord
  class DirectoryPathValidator < ActiveModel::Validator
    def validate(record)
      if record.repository.points_through_file?(record.target_path)
        record.errors[:name] = "Error! This path points to or through a file."
      elsif record.repository.path_exists?(record.target_path)
        record.errors[:name] = "Error! This path already exists."
      end
    end
  end

  attr_accessor :repository, :user, :target_directory, :name
  validates :name, :repository, :user, presence: true
  validates_with DirectoryPathValidator

  def initialize(*args, &block)
    opts = (args.shift || {}).symbolize_keys
    @repository = Repository.find_by_path(opts[:repository_id])
    @user = opts[:user]
    @target_directory = (opts[:repository_directory] || {})[:target_directory]
    @name = (opts[:repository_directory] || {})[:name]
  end

  def save!
    raise RecordNotSavedError unless valid?
    begin
      temp_file = Tempfile.new('.gitkeep')
      message = "Create directory #{name}"
      repository.save_file(temp_file.path, File.join(target_path, '.gitkeep'), message, user)
    ensure
      temp_file.unlink
    end
  end

  def to_s
    name
  end

  def to_param
    path
  end

  def target_path
    @target_directory ||= ''
    File.join(target_directory, name).sub(/^\//, '')
  end
end
