# Module to be included by "subclasses" that use FSSM.
module AxiomSelection::FrequentSymbolSetMining
  extend ActiveSupport::Concern

  MINIMUM_SUPPORT_TYPES = %w(relative absolute)

  included do
    attr_accessible :minimum_support, :minimum_support_type

    validates_numericality_of :minimum_support,
                              greater_than: 0,
                              only_integer: true,
                              if: :minimum_support_absolute?

    validates_numericality_of :minimum_support,
                              greater_than_or_equal_to: 0,
                              less_than_or_equal_to: 100,
                              if: :minimum_support_relative?

    validates_inclusion_of :minimum_support_type,
      in: AxiomSelection::FrequentSymbolSetMining::MINIMUM_SUPPORT_TYPES

    delegate :frequent_symbol_sets, :frequent_symbol_sets=, to: :axiom_selection
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
end
