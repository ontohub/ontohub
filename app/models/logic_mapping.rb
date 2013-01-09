class LogicMapping < ActiveRecord::Base
  include Resourcable
  
  FAITHFULNESSES = %w( none faithful model_expansive model_bijective embedding sublogic )
  THEOROIDALNESSES = %w( plain simple_theoroidal theoroidal generalised )
  
  belongs_to :source, class_name: 'Logic'
  belongs_to :target, class_name: 'Logic'
  
  attr_accessible :source, :target
  
end
