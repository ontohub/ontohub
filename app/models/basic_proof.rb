class BasicProof < ActiveRecord::Base
  belongs_to :translation
  attr_accessible :proof, :prover
end
