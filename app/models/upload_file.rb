class UploadFile

  class PathValidator < ActiveModel::Validator
    def validate(record)
      if record.repository.points_through_file?(record.filepath)
        record.errors[:target_directory] = "Error! This path points to or through a file."
      end
    end
  end


  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attr_accessor :file, :target_directory, :target_filename, :message, :repository

  validates :message, :file, presence: true
  validates_with PathValidator, :if => :file_exists?

  def initialize(attributes = nil)
    attributes ||= {}
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def filename
    if target_filename.present?
      target_filename
    else
      file.original_filename
    end
  end

  def filepath
    target_directory ||= ''
    str  = target_directory
    str  = str[1,-1] if target_directory.starts_with?("/")
    str  = str[0,-2] if target_directory.ends_with?("/")
    str += "/" unless target_directory.empty?
    str += filename
  end

  def file_exists?
    file.present?
  end
end

