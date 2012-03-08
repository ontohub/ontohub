class Permission < ActiveRecord::Base
  belongs_to :ontology
  belongs_to :owner, :polymorphic => true
end
