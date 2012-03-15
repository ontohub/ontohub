class OntologyVersion < ActiveRecord::Base
  include OntologyVersion::Async
  include OntologyVersion::Download
  include OntologyVersion::Parsing

  belongs_to :user
  belongs_to :ontology, :counter_cache => :versions_count

  mount_uploader :raw_file, OntologyUploader
  mount_uploader :xml_file, OntologyUploader

  attr_accessible :raw_file, :source_uri

  validates :raw_file, file_size: { maximum: 10.megabytes.to_i }
# validate :raw_file_xor_source_uri

  scope :latest, order('id DESC')

protected

  def raw_file_xor_source_uri
    if !(raw_file.blank? ^ source_uri.blank?)
      errors.add :source_uri, 'Specify either a source file or URI.'
    end
  end
end
