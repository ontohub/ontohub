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

  def call
    preprocess
    select_axioms
  end

  protected

  def preprocess
    calculate_commonness_table
    calculate_symbol_axiom_trigger_table
  end

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

  def calculate_symbol_axiom_trigger_table
    ontology.all_axioms.each do |axiom|
      axiom.symbols.each do |symbol|
        calculate_symbol_axiom_trigger(symbol, axiom)
      end
    end
  end

  def calculate_symbol_axiom_trigger(symbol, axiom)
    ssat = SineSymbolAxiomTrigger.
      where(symbol_id: symbol.id,
            axiom_id: axiom.id,
            axiom_selection_id: axiom_selection.id).first_or_initialize
    unless ssat.tolerance
      ssat.tolerance = needed_tolerance(symbol, axiom)
      ssat.save!
    end
  end

  def needed_tolerance(symbol, axiom)
    lcs_commonness = commonness_of_least_common_symbol(axiom)
    sym_commonness = symbol.sine_symbol_commonness.commonness
    sym_commonness.to_f / lcs_commonness.to_f
  end

  def least_common_symbol(axiom)
    axiom.symbols.includes(:sine_symbol_commonness).
      order('sine_symbol_commonnesses.commonness ASC').first
  end

  def commonness_of_least_common_symbol(axiom)
    least_common_symbol(axiom).sine_symbol_commonness.commonness
  end

  def select_axioms
    @selected_axioms = []
    select_new_axioms(goal)
    self.axioms = @selected_axioms
  end

  def select_new_axioms(sentence)
    new_axioms = select_axioms_by_sentence(sentence) - @selected_axioms
    @selected_axioms += new_axioms
    new_axioms.each { |axiom| select_new_axioms(axiom) }
  end

  def select_axioms_by_sentence(sentence)
    sentence.symbols.map { |symbol| triggered_axioms(symbol) }.flatten
  end

  def triggered_axioms(symbol)
    Axiom.unscoped.joins(:sine_symbol_axiom_triggers).
      where('sine_symbol_axiom_triggers.symbol_id = ?', symbol.id).
      where('sine_symbol_axiom_triggers.tolerance <= ?', tolerance)
  end
end
