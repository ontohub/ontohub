class SineFresymAxiomSelection < ActiveRecord::Base
  # Pseudo-inheritance from SineAxiomSelection
  include SineAxiomSelection::ClassBody
  include AxiomSelection::FrequentSymbolSetMining

  has_many :symbols, through: :sine_fresym_symbol_sets
  has_many :sine_symbol_commonnesses, through: :symbols

  attr_accessible :symbol_set_tolerance

  validates_numericality_of :symbol_set_tolerance,
                            greater_than_or_equal_to: 1

  protected

  def preprocess
    super
    FrequentSymbolSetsCalculator.new(axiom_selection,
                                     ontology,
                                     minimum_support,
                                     minimum_support_type_option).call
    axiom_selection.reload
  end

  def select_axioms_by_sentence(sentence)
    sentence.symbols.map do |symbol|
      trigger_enabled_symbols(symbol)
    end.flatten.uniq.map do |symbol_id|
      triggered_axioms(OntologyMember::Symbol.find(symbol_id))
    end.flatten.uniq
  end

  # Most common symbols of those frequent symbol sets
  # that include the given symbol.
  def trigger_enabled_symbols(symbol)
    frequent_symbol_sets.
      includes(:frequent_symbols).
      includes(:sine_symbol_commonnesses).
      where('frequent_symbols.symbol_id' => symbol.id).
      map(&:sine_symbol_commonnesses).
      map do |sscs|
        sscs.select do |ssc|
          among_the_most_common?(ssc, sscs)
        end.map(&:symbol_id)
      end.flatten.uniq
  end

  def among_the_most_common?(subject, collection)
    subject.commonness >= collection.map(&:commonness).max/symbol_set_tolerance
  end
end
