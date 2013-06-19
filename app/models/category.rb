class Category < ActiveRecord::Base
  
  has_and_belongs_to_many :ontologies
  
  attr_accessible :name, :parent, :parent_id

  validates :name, :uniqueness => { :message => 'Already taken' }

  has_ancestry

end
