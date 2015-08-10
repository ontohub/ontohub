class AxiomSelection < ActiveRecord::Base
  METHODS = %i(manual_axiom_selection sine_axiom_selection)

  acts_as_superclass

  attr_accessible :finished

  has_many :proof_attempt_configurations
  has_and_belongs_to_many :axioms,
                          class_name: 'Axiom',
                          association_foreign_key: 'sentence_id',
                          join_table: "axioms_axiom_selections"

  def initialize(*args)
    super(*args)
    self.finished = false
  end

  # This seems to be the only way to remove the default scope
  # (non-imported sentences) from the association
  def axioms
    super.where(imported: [true, false])
  end

  def call
    # overwrite this in the "subclasses"
  end

  def ontology
    @ontology ||= goal.ontology
  end

  def goal
    @goal ||= proof_attempt_configurations.first.proof_attempt.theorem
  end

  # This key is used for mutex locking: The selection only has to be done once,
  # but many jobs may call it in parallel.
  def lock_key
    "#{self.class.to_s.underscore.dasherize}-#{id}"
  end

  protected

  def mark_as_finished!
    self.finished = true
    save!
  end
end
