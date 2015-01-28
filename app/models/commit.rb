class Commit < ActiveRecord::Base
  attr_accessible :commit_oid, :repository
  attr_accessible :author, :author_date
  attr_accessible :commit_date, :committer

  has_many :ontology_versions
  has_many :ontologies, through: :ontology_versions

  belongs_to :repository
end
