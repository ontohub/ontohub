class AxiomSelection < ActiveRecord::Base
  METHODS = %i(manual_axiom_selection)

  acts_as_superclass
  has_many :proof_attempt_configurations

  has_and_belongs_to_many :axioms,
                          class_name: 'Axiom',
                          association_foreign_key: 'sentence_id',
                          join_table: "axioms_axiom_selections"

  # This seems to be the only way to remove the default scope
  # (non-imported sentences) from the association
  def axioms
    super.where(imported: [true, false])
  end

  def call
    # overwrite this in the "subclasses"
  end
end
