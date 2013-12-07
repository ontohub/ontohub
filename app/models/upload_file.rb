class UploadFile

  class PathValidator < ActiveModel::Validator
    def validate(record)
      if record.repository.is_below_file?(record.filepath)
        record.errors[:path] = "Error! This path points to a file."
      end
    end
  end


  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attr_accessor :path, :message, :file, :repository

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
    file.original_filename
  end

  def filepath
    str  = path
    str  = str[1,-1] if path.starts_with?("/")
    str  = str[0,-2] if path.ends_with?("/")
    str += "/" unless path.empty?
    str += filename
  end

  def file_exists?
    file.present?
  end
end

