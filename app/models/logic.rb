#
# A named logic in the field of Logics.
#
# Examples:
# * Classical Logic
# * Common Logic
# * Description Logic
# * First-Order Logic
# * Modal Logic
#
class Logic < ActiveRecord::Base
  include Resourcable
  include Permissionable

  has_many :ontologies
  has_many :supports

  # The creator of this logic in the system
  # The logic creator
  # * is not necessarily an owner nor an editor
  # * may be a current or former user of the system
  # * may be the original logician or anyone else
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
  
  def addLanguage(language)
    sup = self.supports.new
    sup.language = language
    sup.save!
  end
  
end
