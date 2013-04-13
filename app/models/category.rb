class Category < ActiveRecord::Base
  include Metadatable
  
  belongs_to :ontology
  
  # attr_accessible :title, :body
end
