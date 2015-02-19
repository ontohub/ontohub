class GeneratedAxiom < ActiveRecord::Base
  belongs_to :proof_attempt
  attr_accessible :name

  def to_s
    name
  end
end
