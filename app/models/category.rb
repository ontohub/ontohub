class Category < ActiveRecord::Base
  include Metadatable
  
  has_and_belongs_to_many :ontologies
  
  attr_accessible :category_id, :name
end
