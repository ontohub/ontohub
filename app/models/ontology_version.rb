class OntologyVersion < ActiveRecord::Base
  include CodeReferencable
  include Numbering

  include OntologyVersion::Files
  include OntologyVersion::States
  include OntologyVersion::Parsing
  include OntologyVersion::Proving
  include OntologyVersion::OopsRequests
  include IRIUrlBuilder::Includeable
  include ::AccessScopesForRepositoryAssociations

  include Rails.application.routes.url_helpers
  include ActionDispatch::Routing::UrlFor

  numbering_parent_column 'ontology_id'

  belongs_to :ontology, :counter_cache => :versions_count
  has_one :repository, through: :ontology
  has_many :theorems, through: :ontology
  has_one :repository, through: :ontology
  has_many :theorems, through: :ontology

  belongs_to :commit
  has_one :author, through: :commit
  has_one :committer, through: :commit
  has_one :pusher, through: :commit

  # Provers that can be used for proving goals in this ontology.
  has_and_belongs_to_many :provers

# before_validation :set_checksum
# validate :raw_file_size_maximum

# validates_presence_of :basepath

  scope :latest, order('id DESC')
  scope :done, state('done')
  scope :failed, state('failed')

  acts_as_tree

  # updated_at of the latest version
  def self.last_updated_at
    latest.first.try(:updated_at)
  end

  def to_param
    self.number
  end

  def to_s
    "#{ontology.name} (version #{number})"
  end

  # Public URL to this version
  #
  # TODO: This returns a path without the commit id and filename for now,
  # because the FilesController or the routes were not supporting it.
  def url(params={})
    #Rails.application.routes.url_helpers.repository_ref_path(repository, commit_oid, ontology.path, params.reverse_merge(host: Ontohub::Application.config.fqdn, port: Ontohub::Application.config.port, only_path: false))
    url_for [repository, ontology, self]
  end

  def default_url_options
    {host: Ontohub::Application.config.fqdn,
     port: Ontohub::Application.config.port}
  end

  def path
    "#{basepath}#{file_extension}"
  end

  def file_in_repository
    ontology.repository.get_file(path, commit_oid)
  end

  def locid
    "/ref/#{number}#{ontology.locid}"
  end

  alias_method :versioned_locid, :locid

  def latest_version?
    ontology.versions.last == self
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
