class LogicMapping < ActiveRecord::Base
  
  FAITHFULNESSES = %w( faithful model_expansive model_bijective embedding sublogic )
  THEOROIDALNESSES = %w( plain simple_theoroidal theoroidal generalised )
end
