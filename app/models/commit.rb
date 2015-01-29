class Commit < ActiveRecord::Base
  attr_accessible :commit_oid, :repository
  attr_accessible :author, :author_date
  attr_accessible :commit_date, :committer

  has_many :ontology_versions
  has_many :ontologies, through: :ontology_versions

  belongs_to :repository

  def fill_commit_instance!
    commit = repository.git.repo.lookup(commit_oid)
    data = commit.committer
    self.committer = "#{data[:name]} <#{data[:email]}>"
    self.commit_date = data[:time]
    data = commit.author
    self.author = "#{data[:name]} <#{data[:email]}>"
    self.author_date = data[:time]
    save!
  end
end
