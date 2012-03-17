class Logic < ActiveRecord::Base
  has_many :ontologies

  attr_accessible :name, :uri, :extension, :mimetype

  validates_presence_of :name
  validates_uniqueness_of :name, if: :name_changed?

  validates_presence_of :uri
  validates_uniqueness_of :uri, if: :uri_changed?
  validates_format_of :uri, with: URI::regexp(ALLOWED_URI_SCHEMAS)

  validates :extension, length: { minimum: 1, maximum: 10 }

  validates_format_of :mimetype, with: /.*\/.*/
  
  def to_s
    name
  end
end
