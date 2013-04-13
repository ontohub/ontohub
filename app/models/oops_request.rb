class OopsRequest < ActiveRecord::Base
  belongs_to :ontology_version
  attr_accessible :last_error, :state
end
