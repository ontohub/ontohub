class SineFresymSymbolSet < ActiveRecord::Base
  belongs_to :sine_fresym_axiom_selection
  has_many :sine_fresym_symbols, dependent: :destroy
  has_many :symbols, through: :sine_fresym_symbols, dependent: :destroy,
           class_name: OntologyMember::Symbol
  has_many :sine_symbol_commonnesses, through: :symbols
end
