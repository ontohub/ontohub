class OntologyVersion < ActiveRecord::Base
  include OntologyVersion::Parsing

  belongs_to :user
  belongs_to :ontology, :counter_cache => :versions_count

  mount_uploader :raw_file, OntologyUploader
  mount_uploader :xml_file, OntologyUploader

  attr_accessible :raw_file, :remote_raw_file_url

  validate :validates_size_of_raw_file, :if => :raw_file?

  scope :latest, order('id DESC')

  before_create :set_source_uri

  def set_source_uri
    self.source_uri = self.remote_raw_file_url
  end

protected

  def validates_size_of_raw_file
    if raw_file.size > 10.megabytes.to_i
      errors.add :raw_file, 'Maximum upload size is 10M.'
    end
  end
end
