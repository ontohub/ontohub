class GeneratedAxiom < ActiveRecord::Base
  belongs_to :proof_attempt
  attr_accessible :name

  alias_attribute :to_s, :name
end
