class FrequentSymbol < ActiveRecord::Base
  belongs_to :frequent_symbol_set
  belongs_to :symbol
end
