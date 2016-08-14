class ProverOutput < ActiveRecord::Base
  belongs_to :proof_attempt
  has_one :ontology, through: :proof_attempt
  has_one :theorem, through: :proof_attempt
  has_one :prover, through: :proof_attempt
  attr_accessible :content, :locid
end
