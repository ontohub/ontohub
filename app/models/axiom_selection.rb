class AxiomSelection < ActiveRecord::Base
  acts_as_superclass
  has_one :proof_attempt_configuration

  has_and_belongs_to_many :axioms,
                          class_name: 'Axiom',
                          association_foreign_key: 'sentence_id',
                          join_table: "axioms_axiom_selections"

  validate :proof_attempt_configuration, presence: true

  # This seems to be the only way to remove the default scope
  # (non-imported sentences) from the association
  def axioms
    super.where(imported: [true, false])
  end
end
