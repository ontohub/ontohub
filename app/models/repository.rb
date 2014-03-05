class Repository < ActiveRecord::Base

  include Permissionable

  include Repository::Access
  include Repository::FilesList
  include Repository::GitRepositories
  include Repository::Importing
  include Repository::Ontologies
  include Repository::Scopes
  include Repository::Symlink
  include Repository::Validations

  has_many :ontologies, dependent: :destroy
  has_many :url_maps, dependent: :destroy

  attr_accessible :name,
                  :description,
                  :source_type,
                  :source_address,
                  :access,
                  :is_destroying
  attr_accessor :user

  after_save :clear_readers
  before_destroy :mark_as_destroying, prepend: true

  scope :latest, order('updated_at DESC')

  def to_s
    name
  end

  def to_param
    path
  end

  protected

  def mark_as_destroying
    self.is_destroying = true
    save
  end

end
