class UploadFile

  include ActiveModel::Conversion
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attr_accessor :path, :message, :file

  validates :message, :file, presence: true

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

end