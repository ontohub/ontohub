class Logic < ActiveRecord::Base
  include Resourcable
  include Permissionable

  has_many :ontologies
  has_many :supports
  
  belongs_to :user

  attr_accessible :name, :iri, :description, :standardization_status, :defined_by

  validates_presence_of :name
  validates_uniqueness_of :name, if: :name_changed?

  validates_presence_of :iri
  validates_uniqueness_of :iri, if: :iri_changed?
  #validates_format_of :iri, with: URI::regexp(ALLOWED_URI_SCHEMAS)

  def to_s
    name
  end
end
