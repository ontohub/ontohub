class Repository < ActiveRecord::Base

  include Permissionable
  include Repository::GitRepositories
  include Repository::Validations

  has_many :ontologies

  attr_accessible :name, :description


  def to_s
    name
  end

  def to_param
    path
  end
  
end
