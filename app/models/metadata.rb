class Metadata < ActiveRecord::Base
  belongs_to :metadatable, :polymorphic => true
end
