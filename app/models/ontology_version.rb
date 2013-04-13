class OntologyVersion < ActiveRecord::Base
  include OntologyVersion::States
  include OntologyVersion::Download
  include OntologyVersion::Parsing
  include OntologyVersion::Numbers

  belongs_to :user
  belongs_to :ontology, :counter_cache => :versions_count
  has_one :request, class_name: 'OopsRequest'

  mount_uploader :raw_file, OntologyUploader
  mount_uploader :xml_file, OntologyUploader

  attr_accessible :raw_file, :source_url

  before_validation :set_checksum

  validate :presence_of_raw_file_or_source_url, :on => :create
#  validate :raw_file_size_maximum

  validates_format_of :source_url,
    :with => URI::regexp(ALLOWED_URI_SCHEMAS), :if => :source_url?

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

  def presence_of_raw_file_or_source_url
    if raw_file.blank? and source_url.blank?
      errors.add :source_url, 'Specify either a source file or URI.'
    end
  end
 
  def raw_file_size_maximum
    if raw_file.size > 10.megabytes.to_i
      errors.add :raw_file, 'The maximum file size is 10M.'
    end
  end

  def set_checksum
    self.checksum = raw_file.sha1 if raw_file.present? and raw_file_changed?
  end
end
