class FrequentSymbolSetMiningAxiomSelection < ActiveRecord::Base
  include AxiomSelection::FrequentSymbolSetMining

  acts_as :axiom_selection

  attr_accessible :short_axiom_tolerance, :minimal_symbol_set_size, :depth_limit

  validates_numericality_of :short_axiom_tolerance,
                            greater_than_or_equal_to: 0,
                            only_integer: true

  validates_numericality_of :minimal_symbol_set_size,
                            greater_than_or_equal_to: 2,
                            only_integer: true

  # Special case: The depth limit of -1 is considered to be infinite.
  validates_numericality_of :depth_limit,
    greater_than_or_equal_to: -1,
    only_integer: true

  delegate :goal, :ontology, :lock_key, :mark_as_finished!, to: :axiom_selection

  def call
    Semaphore.exclusively(lock_key) do
      unless finished
        record_processing_time do
          transaction do
            preprocess unless other_finished_axiom_selections(self.class).any?
            select_axioms
            mark_as_finished!
          end
        end
      end
    end
  end

  protected

  def preprocess
    FrequentSymbolSetsCalculator.new(axiom_selection,
                                     ontology,
                                     minimum_support,
                                     minimum_support_type_option,
                                     minimal_symbol_set_size).call
    axiom_selection.reload
  end

  def select_axioms
    prepare_axiom_symbols
    @selected_axioms = []
    select_new_axioms(goal, 0)
    self.axioms = @selected_axioms.uniq
  end

  def prepare_axiom_symbols
    @axioms_symbols_ids_hash = {}
    ontology.axioms.find_each do |axiom|
      @axioms_symbols_ids_hash[axiom] = axiom.symbols.map(&:id).to_set
    end
  end

  def short_axioms
    @short_axioms ||= ontology.axioms.
      select('sentences.*, count(symbols.id) as symbols_count').
      joins(:symbols).
      group('sentences.id').
      having('count(symbols.id) < ?',
             minimal_symbol_set_size + short_axiom_tolerance)
  end

  def select_new_axioms(sentence, current_depth)
    return if depth_limit_reached?(current_depth)
    new_axioms =
      if current_depth == 0
        short_axioms + select_axioms_by_sentence(sentence)
      else
        select_axioms_by_sentence(sentence) - @selected_axioms
      end
    @selected_axioms += new_axioms
    new_axioms.each { |axiom| select_new_axioms(axiom, current_depth + 1) }
  end

  def select_axioms_by_sentence(sentence)
    sentence.symbols.map { |symbol| selected_axioms(symbol) }.flatten
  end

  def selected_axioms(symbol)
    selected = []
    selection_enabled_symbol_sets(symbol).map do |frequent_symbol_set|
      selection_enabled_symbol_ids = frequent_symbol_set.symbols.all.map(&:id).to_set

      @axioms_symbols_ids_hash.each do |axiom, symbol_ids|
        selected << axiom if symbol_ids.subset?(selection_enabled_symbol_ids)
      end
    end
    selected.uniq
  end

  def selection_enabled_symbol_sets(symbol)
    frequent_symbol_sets.includes(:frequent_symbols).
      where('frequent_symbols.symbol_id' => symbol.id)
  end

  def depth_limit_reached?(current_depth)
    depth_limited? && current_depth >= depth_limit
  end

  def depth_limited?
    depth_limit != -1
  end
end
