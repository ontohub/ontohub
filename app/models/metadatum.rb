class Metadatum < ActiveRecord::Base
  belongs_to :metadatable, :polymorphic => true
  belongs_to :user

  attr_accessible :key, :value
end
