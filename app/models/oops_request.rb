class OopsRequest < ActiveRecord::Base

  belongs_to :ontology_version

  include OopsRequest::States
  include OopsRequest::Responses

end
