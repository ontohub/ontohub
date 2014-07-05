class EntityGroup < ActiveRecord::Base
  extend Dagnabit::Vertex::Activation
  belongs_to :ontology
  has_many :entities

  attr_accessible :ontology, :name, :entities

  acts_as_vertex
  connected_by 'EEdge'

  def to_s
    name
  end
end
