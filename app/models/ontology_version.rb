class OntologyVersion < ActiveRecord::Base
  include CodeReferencable

  include OntologyVersion::Files
  include OntologyVersion::States
  include OntologyVersion::Parsing
  include OntologyVersion::Numbers
  include OntologyVersion::OopsRequests

  include Rails.application.routes.url_helpers
  include ActionDispatch::Routing::UrlFor

  belongs_to :user
  belongs_to :ontology, :counter_cache => :versions_count

# before_validation :set_checksum
# validate :raw_file_size_maximum

  validates_format_of :source_url,
    :with => URI::regexp(Settings.allowed_iri_schemes), :if => :source_url?
  validates_presence_of :basepath

  scope :latest, order('id DESC')
  scope :done, state('done')
  scope :failed, state('failed')

  delegate :repository, to: :ontology

  # updated_at of the latest version
  def self.last_updated_at
    latest.first.try(:updated_at)
  end

  def to_param
    self.number
  end

  # Public URL to this version
  #
  # TODO: This returns a path without the commit id and filename for now,
  # because the FilesController or the routes were not supporting it.
  def url(params={})
    #Rails.application.routes.url_helpers.repository_ref_path(repository, commit_oid, ontology.path, params.reverse_merge(host: Settings.hostname, only_path: false))
    url_for [repository, ontology, self]
  end

  def default_url_options
    {host: Settings.hostname}
  end

  def path
    "#{basepath}#{file_extension}"
  end

  protected

  def raw_file_size_maximum
    if raw_file.size > 10.megabytes.to_i
      errors.add :raw_file, 'The maximum file size is 10M.'
    end
  end

  def refresh_checksum!
    self.checksum = Digest::SHA1.file(raw_path!).hexdigest
    save! if checksum_changed?
  end

end
