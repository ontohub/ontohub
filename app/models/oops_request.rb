class OopsRequest < ActiveRecord::Base
  belongs_to :ontology_version
  has_many :responses, class_name: 'OopsResponse'

  attr_accessible :last_error, :state
end
