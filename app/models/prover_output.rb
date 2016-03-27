class ProverOutput < LocIdBaseModel
  belongs_to :proof_attempt
  has_one :ontology, through: :proof_attempt
  has_one :theorem, through: :proof_attempt
  has_one :prover, through: :proof_attempt
  attr_accessible :content, :locid

  def generate_locid_string
    "#{proof_attempt.locid}//prover-output"
  end
end
