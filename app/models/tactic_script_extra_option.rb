class TacticScriptExtraOption < ActiveRecord::Base
  belongs_to :tactic_script
  attr_accessible :option
  validates :option, presence: true
end
