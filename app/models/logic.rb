class Logic < ActiveRecord::Base
  has_many :ontologyVersions
  has_many :supports

  attr_accessible :name, :uri, :extension, :mimetype

  validates_presence_of :name
  validates_uniqueness_of :name, if: :name_changed?
  validates :name, length: { minimum: 1 }
  validates :iri, length: { minimum: 1 }

  validates_presence_of :iri
  validates_uniqueness_of :iri, if: :iri_changed?
  validates_format_of :iri, with: iri::regexp(ALLOWED_URI_SCHEMAS)

  validates :extension, length: { minimum: 1, maximum: 10, allow_blank: true }

  validates_format_of :mimetype, with: /[0-9a-z+-]+\/[0-9a-z+-]+/, allow_blank: true
  
  def to_s
    name
  end
end
