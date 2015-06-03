class TacticScriptExtraOption < ActiveRecord::Base
  belongs_to :tactic_script
  attr_accessible :option
  validates :option, presence: true

  def to_s
    option
  end
end
