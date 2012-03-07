class Entity < ActiveRecord::Base
  belongs_to :ontology
  has_and_belongs_to_many :axioms
end
