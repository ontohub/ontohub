class SineFresymSymbol < ActiveRecord::Base
  belongs_to :sine_fresym_symbol_set
  belongs_to :symbol
end
