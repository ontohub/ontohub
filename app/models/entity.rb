class Entity < ActiveRecord::Base

 
  include Metadatable
  include Entity::Searching
  include Entity::Readability

  belongs_to :ontology
  belongs_to :entity_group
  has_and_belongs_to_many :sentences
  has_and_belongs_to_many :oops_responses

  attr_accessible :label, :comment

  scope :kind, ->(kind) { where :kind => kind }


  def self.groups_by_kind
    groups = select('kind, count(*) AS count').group(:kind).order('count DESC, kind').all
    groups << Struct.new(:kind, :count).new("Symbol",0) if groups.empty?
    groups
  end
  
  def to_s
    self.display_name || self.name
  end
  
end
