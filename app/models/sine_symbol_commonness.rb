class SineSymbolCommonness < ActiveRecord::Base
  belongs_to :symbol, class_name: OntologyMember::Symbol
  belongs_to :axiom_selection
  attr_accessible :commonness
end
