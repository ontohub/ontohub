class FrequentSymbolSet < ActiveRecord::Base
  belongs_to :axiom_selection
  has_many :frequent_symbols, dependent: :destroy
  has_many :symbols, through: :frequent_symbols, dependent: :destroy,
           class_name: OntologyMember::Symbol

  # Only if the axiom_selection is a Sine*AxiomSelection:
  has_many :sine_symbol_commonnesses, through: :symbols
end
