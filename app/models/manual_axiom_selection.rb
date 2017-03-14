class ManualAxiomSelection < ActiveRecord::Base
  acts_as :axiom_selection
  has_many :proof_attempts, through: :axiom_selection
end
