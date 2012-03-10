class OntologyVersion < ActiveRecord::Base
  belongs_to :user
  belongs_to :ontology

  mount_uploader :raw_file, OntologyUploader
  mount_uploader :xml_file, OntologyUploader

  attr_accessible :raw_file, :source_uri
end
