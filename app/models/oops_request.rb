class OopsRequest < ActiveRecord::Base
  belongs_to :ontology_version
  has_many :oops_responses
  attr_accessible :last_error, :state
end
