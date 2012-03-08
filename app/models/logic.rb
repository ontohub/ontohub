class Logic < ActiveRecord::Base
  
  has_many :ontologies
  
  def to_s
    name
  end
  
end
