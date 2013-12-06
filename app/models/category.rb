class Category < ActiveRecord::Base

  extend Dagnabit::Vertex::Activation
  
  has_and_belongs_to_many :ontologies
  attr_accessible :name, :ontologies

  acts_as_vertex
  connected_by 'CEdge'
  
  def relatedOntologies
    categories = [self]+[self.children] 
    Ontology.where(:category => [categories])
  end

# has_and_belongs_to_many :ontologies
  
# attr_accessible :name, :parent, :parent_id

# validates :name, :uniqueness => { :scope => :ancestry, :message => 'Already taken' }

# has_ancestry

# def self.arrange_as_array(options={}, hash=nil)

#   hash ||= arrange(options)

#   arr = []
#   hash.each do |node, children|
#     arr << node
#     arr += arrange_as_array(options, children) unless children.nil?
#   end
#   arr
# end

# def name_for_selects
#   "#{'-' * depth} #{name}"
# end

# def possible_parents
#   parents = Category.arrange_as_array(:order => 'name')
#   return new_record? ? parents : parents - subtree
# end

# def to_s
#   name
# end

end
