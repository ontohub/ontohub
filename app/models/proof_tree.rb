class ProofTree < ActiveRecord::Base
  belongs_to :proof_status

  attr_accessible :tree

  strip_attributes
end
