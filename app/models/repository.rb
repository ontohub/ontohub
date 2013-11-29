class Repository < ActiveRecord::Base

  include Permissionable
  include Repository::Ontologies
  include Repository::GitRepositories
  include Repository::FilesList
  include Repository::Validations
  include Repository::Importing
  include Repository::Scopes
  include Repository::Symlink

  has_many :ontologies, dependent: :destroy
  has_many :url_maps, dependent: :destroy

  attr_accessible :name, :description, :source_type, :source_address, :private_flag
  attr_accessor :user

  scope :latest, order('updated_at DESC')

  def to_s
    name
  end

  def to_param
    path
  end
  
end
