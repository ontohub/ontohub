class Entity < ActiveRecord::Base

  extend Dagnabit::Vertex::Activation

  include Metadatable
  include Entity::Searching
  include Entity::Readability

  belongs_to :ontology
  has_and_belongs_to_many :sentences
  has_and_belongs_to_many :oops_responses

  attr_accessible :label, :comment

  scope :kind, ->(kind) { where :kind => kind }

  acts_as_vertex
  connected_by 'EEdge'

  def self.groups_by_kind
    groups = select('kind, count(*) AS count').group(:kind).order('count DESC, kind').all
    groups << Struct.new(:kind, :count).new("Symbol",0) if groups.empty?
    groups
  end
  
  def to_s
    self.display_name || self.name
  end
  
end
