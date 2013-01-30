class Language < ActiveRecord::Base
  include Resourcable
  include Permissionable

  has_many :supports
  has_many :language_adjoints
  has_many :ontologies
  has_many :serializations
  
  belongs_to :user

  attr_accessible :name, :iri, :description, :standardization_status, :defined_by

  validates :name, length: { minimum: 1 }

  validates :iri, length: { minimum: 1 }
  validates_uniqueness_of :iri, if: :iri_changed?
  validates_format_of :iri, with: URI::regexp(ALLOWED_URI_SCHEMAS)

  def to_s
    name
  end
  
  def addLogic(logic)
    sup = self.supports.new
    sup.logic = logic
    sup.save!
  end
end
