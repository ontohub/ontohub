class OopsRequest < ActiveRecord::Base
  
  # Queue for Resque
  @queue = :oops
  
  belongs_to :ontology_version
  
  include OopsRequest::States
  include OopsRequest::Responses
  
end
