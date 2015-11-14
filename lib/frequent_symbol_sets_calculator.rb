class FrequentSymbolSetsCalculator
  attr_accessor :axiom_selection, :ontology
  attr_accessor :minimum_support, :minimum_support_type_option
  attr_accessor :minimal_symbol_set_size

  def initialize(axiom_selection, ontology,
                 minimum_support, minimum_support_type_option,
                 minimal_symbol_set_size = 2)
    self.axiom_selection = axiom_selection
    self.ontology = ontology
    self.minimum_support = minimum_support
    self.minimum_support_type_option = minimum_support_type_option
    self.minimal_symbol_set_size = minimal_symbol_set_size
  end

  def call
    save_symbol_id_sets(symbol_id_sets)
  end

  protected

  def save_symbol_id_sets(symbol_id_sets)
    ActiveRecord::Base.transaction do
      symbol_id_sets.each do |symbol_id_set|
        fss_set = FrequentSymbolSet.new
        fss_set.axiom_selection = axiom_selection
        fss_set.frequent_symbols =
          symbol_id_set.map do |symbol_id|
            fs = FrequentSymbol.new
            fs.frequent_symbol_set = fss_set
            fs.symbol_id = symbol_id
            fs.save!
            fs
          end
        fss_set.save!
      end
    end
  end

  def symbol_id_sets
    @symbol_id_sets ||=
      begin
        fpgrowth = FISMFPGrowth.new(transactions,
                                    target_type: :maximal_item_sets,
                                    minimum_support: minimum_support,
                                    minimum_support_type: minimum_support_type_option)
        patterns = fpgrowth.call.map { |pattern| pattern.map(&:to_i) }
        patterns.select { |p| p.size >= minimal_symbol_set_size }
      end
  end

  def transactions
    @transactions ||=
      begin
        symbol_bag = ontology.all_axioms.select(&:id).map do |axiom|
          axiom.symbols.select(&:id).map(&:id)
        end
        symbol_bag << axiom_selection.goal.symbols.select(&:id).map(&:id)
      end
  end
end
