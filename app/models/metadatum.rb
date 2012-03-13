class Metadatum < ActiveRecord::Base
  belongs_to :metadatable, :polymorphic => true
  belongs_to :user

  attr_accessible :key, :value

  validates_format_of :key,
    :with => URI::regexp(ALLOWED_URI_SCHEMAS),
    :if => :key?

end
