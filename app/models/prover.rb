class Prover < ActiveRecord::Base
  attr_accessible :name, :display_name

  def to_s
    display_name
  end
end
