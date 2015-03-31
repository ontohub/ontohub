class Prover < ActiveRecord::Base
  attr_accessible :name

  def to_s
    name
  end
end
