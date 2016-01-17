class ProverOutput < OntohubBaseModel
  belongs_to :proof_attempt
  has_one :ontology, through: :proof_attempt
  has_one :theorem, through: :proof_attempt
  has_one :prover, through: :proof_attempt
  attr_accessible :content, :locid

  before_create :generate_locid

  protected

  def generate_locid
    LocId.first_or_create!(locid: "#{proof_attempt.locid}//prover-output",
                          assorted_object: self)
  end
end
