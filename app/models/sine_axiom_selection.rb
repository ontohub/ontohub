class SineAxiomSelection < ActiveRecord::Base
  acts_as :axiom_selection

  attr_accessible :commonness_threshold, :depth_limit, :tolerance

  validates_numericality_of :commonness_threshold,
                            greater_than_or_equal_to: 0,
                            only_integer: true
  # Special case: The depth limit of -1 is considered to be infinite.
  validates_numericality_of :depth_limit,
                            greater_than_or_equal_to: -1,
                            only_integer: true
  validates_numericality_of :tolerance, greater_than_or_equal_to: 1

  delegate :mark_as_finished!, to: :axiom_selection

  protected

  def calculate_commonness_table
    ontology.symbols.each { |symbol| calculate_commonness(symbol) }
  end

  # Number of axioms in which the symbol occurs
  def calculate_commonness(symbol)
    ssc = SineSymbolCommonness.
      where(symbol_id: symbol.id,
            axiom_selection_id: axiom_selection.id).first_or_initialize
    unless ssc.commonness
      ssc.commonness = query_commonness(symbol)
      ssc.save!
    end
  end

  def query_commonness(symbol)
    ontology.all_axioms.joins(:symbols).where(:'symbols.id' => symbol.id).count
  end
end
