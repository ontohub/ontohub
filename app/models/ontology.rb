class Ontology < ActiveRecord::Base
  
  include Commentable
  include Permissionable
  include Metadatable

  include Ontology::Entities
  include Ontology::Sentences
  include Ontology::Import
  include Ontology::States
  include Ontology::Versions

  belongs_to :language
  belongs_to :version
  has_many :versions

  attr_accessible :uri, :name, :description, :logic_id

  validates_presence_of :uri
  validates_uniqueness_of :uri, :if => :uri_changed?
  validates_format_of :uri, :with => URI::regexp(ALLOWED_URI_SCHEMAS)
  
  strip_attributes :only => [:name, :uri]

  scope :search, ->(query) { where "uri LIKE :term OR name LIKE :term", :term => "%" << query << "%" }

  def to_s
    name? ? name : uri
  end
  
  # title for links
  def title
    name? ? uri : nil
  end
  
end
