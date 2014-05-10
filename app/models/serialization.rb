class Serialization < ActiveRecord::Base
  belongs_to :language
  validates_presence_of :name, :mimetype

  attr_accessible :name, :extension, :mimetype, :language_id

  MIMETYPES = %w( text image video audio application multipart message model example )

  def to_s
    name
  end

  def full_name
    "#{name}.#{extension}"
  end

  def full_name_with_type
    "#{full_name} (#{mimetype})"
  end
end
