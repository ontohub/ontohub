class OntologyVersion < ActiveRecord::Base
  include OntologyVersion::States
  include OntologyVersion::Download
  include OntologyVersion::Parsing
  include OntologyVersion::Numbers
  include OntologyVersion::OopsRequests
  
  belongs_to :user
  belongs_to :ontology, :counter_cache => :versions_count

  mount_uploader :raw_file, OntologyUploader
  mount_uploader :xml_file, OntologyUploader

  attr_accessible :raw_file, :source_url

  before_validation :set_checksum

  # validate :raw_file_size_maximum

  validates_format_of :source_url,
    :with => URI::regexp(Settings.allowed_iri_schemes), :if => :source_url?

  scope :latest, order('id DESC')
  scope :state, ->(state) { where :state => state }
  scope :done, state('done')
  scope :failed, state('failed')

  # updated_at of the latest version
  def self.last_updated_at
    latest.first.try(:updated_at)
  end
  
  def source_name
    source_url? ? source_url : 'File upload'
  end
  
  def to_param
    self.number
  end
  
  # public URL to this version
  def url(params={})
    Rails.application.routes.url_helpers.ontology_ontology_version_path(ontology, self, params.reverse_merge(host: Settings.hostname, only_path: false))
  end
 
protected

  def raw_file_size_maximum
    if raw_file.size > 10.megabytes.to_i
      errors.add :raw_file, 'The maximum file size is 10M.'
    end
  end

  def set_checksum
    self.checksum = raw_file.sha1 if raw_file.present? and raw_file_changed?
  end
end
