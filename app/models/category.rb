class Category < ActiveRecord::Base
  
  has_and_belongs_to_many :ontologies
  
  attr_accessible :name

  validates :name, :uniqueness => { :message => 'Already taken' }

end
