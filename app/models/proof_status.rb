class ProofStatus < ActiveRecord::Base
  self.primary_key = :identifier

  attr_accessible :label, :description, :identifier, :name, :category

  validates_presence_of :label

  def to_s
    identifier
  end

  def to_param
    identifier
  end

  def decisive?
    %w(solved deductive preserving).include?(category)
  end
end
