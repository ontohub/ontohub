class Repository < ActiveRecord::Base
  include Permissionable
  include Repository::Access
  include Repository::AssociationsAndAttributes
  include Repository::Destroying
  include Repository::Git
  include Repository::Importing
  include Repository::Ontologies
  include Repository::Scopes
  include Repository::Symlink
  include Repository::Validations

  DEFAULT_CLONE_TYPE = 'git'

  class Error < ::StandardError; end
  class DeleteError < Error; end

  attr_accessor :user

  before_validation :set_path
  after_save :clear_readers

  scope :latest, order('updated_at DESC')

  def to_s
    name
  end

  def to_param
    path
  end

  def blank?
    !self
  end

  def set_path
    self.path ||= name.parameterize if name
  end
end
