class Category < ActiveRecord::Base

  extend Dagnabit::Vertex::Activation

  has_and_belongs_to_many :ontologies
  attr_accessible :name, :ontologies

  acts_as_vertex
  connected_by 'CEdge'

  def related_ontologies
    categories = [self] + self.descendants
    ontologies = Ontology.joins(:categories).where(categories: {id: categories})
  end

end
