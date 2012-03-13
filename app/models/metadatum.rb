class Metadatum < ActiveRecord::Base
  belongs_to :metadatable, :polymorphic => true
  belongs_to :user

  attr_accessible :key, :value

  # TODO This validates correctly but does not throw the possible validation
  #      error (on disallowed uri schemas) up to the form on
  #      ontology_metadata_path
  validates_format_of :key,
    :with => URI::regexp(ALLOWED_URI_SCHEMAS),
    :if => :key?

end
