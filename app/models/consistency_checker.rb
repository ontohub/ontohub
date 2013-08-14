#
# A named consistency checker.
#
# Examples:
# * Hermit
# * FaCT++
#
class ConsistencyChecker < ActiveRecord::Base
  include Resourcable

  has_many :methods, :foreign_key => :checker_id
  attr_accessible :name

  validates_presence_of :name
  validates_uniqueness_of :name, if: :name_changed?

  def add_logic(logic)
    method = self.methods.new
    method.logic = logic
    method.save!
  end
end
