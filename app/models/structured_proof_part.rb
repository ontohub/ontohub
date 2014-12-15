class StructuredProofPart < ActiveRecord::Base
  belongs_to :structured_proof
  belongs_to :sentence
  belongs_to :mapping_version
  # attr_accessible :title, :body
end
