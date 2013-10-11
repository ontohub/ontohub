class Repository < ActiveRecord::Base

  include Permissionable
  include Repository::GitRepositories
  include Repository::FilesList
  include Repository::Validations
  include Repository::Importing

  has_many :ontologies, dependent: :destroy

  attr_accessible :name, :description, :source_type, :source_address
  attr_accessor :user

  def to_s
    name
  end

  def to_param
    path
  end
  
end
