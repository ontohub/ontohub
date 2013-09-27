class Repository < ActiveRecord::Base

  include Permissionable
  include Repository::GitRepositories
  include Repository::FilesList
  include Repository::Validations

  has_many :ontologies

  attr_accessible :name, :description
  attr_accessor :user

  def to_s
    name
  end

  def to_param
    path
  end
  
end
