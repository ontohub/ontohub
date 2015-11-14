class SineFresymAxiomSelection < ActiveRecord::Base
  # Pseudo-inheritance from SineAxiomSelection
  include SineAxiomSelection::ClassBody

  MINIMUM_SUPPORT_TYPES = %w(relative absolute)

  has_many :sine_fresym_symbol_sets, dependent: :destroy
  has_many :symbols, through: :sine_fresym_symbol_sets
  has_many :sine_symbol_commonnesses, through: :symbols

  attr_accessible :minimum_support, :minimum_support_type
  attr_accessible :symbol_set_tolerance

  validates_numericality_of :minimum_support,
                            greater_than: 0,
                            only_integer: true,
                            if: :minimum_support_absolute?

  validates_numericality_of :minimum_support,
                            greater_than_or_equal_to: 0,
                            less_than_or_equal_to: 100,
                            if: :minimum_support_relative?

  validates_numericality_of :symbol_set_tolerance,
                            greater_than_or_equal_to: 1

  validates_inclusion_of :minimum_support_type, in: MINIMUM_SUPPORT_TYPES

  protected

  def preprocess
    super
    calculate_frequent_symbolsets
  end

  def calculate_frequent_symbolsets
    fpgrowth = FISMFPGrowth.new(transactions,
                                target_type: :maximal_item_sets,
                                minimum_support: minimum_support,
                                minimum_support_type: minimum_support_type_option)
    patterns = fpgrowth.call.map { |pattern| pattern.map(&:to_i) }
    symbol_id_sets = patterns.select { |p| p.size > 1 }
    save_symbol_id_sets(symbol_id_sets)
  end

  def cleanup
    super
    sine_fresym_symbol_sets.each(&:destroy)
  end

  def transactions
    @transactions ||=
      begin
        symbol_bag = ontology.all_axioms.select(&:id).map do |axiom|
          axiom.symbols.select(&:id).map(&:id)
        end
        symbol_bag << goal.symbols.select(&:id).map(&:id)
      end
  end

  def save_symbol_id_sets(symbol_id_sets)
    transaction do
      symbol_id_sets.each do |symbol_id_set|
        sfs_set = SineFresymSymbolSet.new
        sfs_set.sine_fresym_axiom_selection = self
        sfs_set.sine_fresym_symbols =
          symbol_id_set.map do |symbol_id|
            sfs = SineFresymSymbol.new
            sfs.sine_fresym_symbol_set = sfs_set
            sfs.symbol_id = symbol_id
            sfs.save!
            sfs
          end
        sfs_set.save!
      end
    end
  end

  def minimum_support_type_option
    minimum_support_absolute? ? :absolute : :relative
  end

  def minimum_support_absolute?
    minimum_support_type == 'absolute'
  end

  def minimum_support_relative?
    !minimum_support_absolute?
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
    sine_fresym_symbol_sets.
      includes(:sine_fresym_symbols).
      includes(:sine_symbol_commonnesses).
      where('sine_fresym_symbols.symbol_id' => symbol.id).
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
