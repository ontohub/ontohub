class Axiom < Sentence
  has_many :sine_symbol_axiom_triggers, dependent: :destroy
end
