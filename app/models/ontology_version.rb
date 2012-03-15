class OntologyVersion < ActiveRecord::Base
  include OntologyVersion::Parsing

  belongs_to :user
  belongs_to :ontology, :counter_cache => :versions_count

  mount_uploader :raw_file, OntologyUploader
  mount_uploader :xml_file, OntologyUploader

  attr_accessible :raw_file, :remote_raw_file_url

  validates :raw_file, file_size: { maximum: 10.megabytes.to_i }
  validate :raw_file_xor_remote_raw_file_url

  scope :latest, order('id DESC')

  before_create :set_source_uri

  def set_source_uri
    self.source_uri = self.remote_raw_file_url
  end

protected

  def raw_file_xor_remote_raw_file_url
    if !(raw_file.blank? ^ source_uri.blank?)
      errors.add :remote_raw_file_url, 'Specify either a source file or URI.'
    end
  end
end
