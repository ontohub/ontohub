class ProverOutput < LocIdBaseModel
  belongs_to :proof_attempt
  has_one :ontology, through: :proof_attempt
  has_one :theorem, through: :proof_attempt
  has_one :prover, through: :proof_attempt
  attr_accessible :content, :locid

  after_create :generate_locid

  protected

  def generate_locid
    LocId.where(locid: "#{proof_attempt.locid}//prover-output",
                assorted_object_id: self.id,
                assorted_object_type: self.class,).first_or_create!
  end
end
