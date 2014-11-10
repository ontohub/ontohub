class TacticScript < ActiveRecord::Base
  belongs_to :proof_status

  attr_accessible :script

  strip_attributes

  validates :script, presence: true
end
