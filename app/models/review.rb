class Review < ActiveRecord::Base
  belongs_to :ontology
  attr_accessible :text
end
