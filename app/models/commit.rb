class Commit < ActiveRecord::Base
  attr_accessible :commit_oid, :repository
  attr_accessible :author_name, :author_email, :author_date
  attr_accessible :committer_name, :author_email, :commit_date

  belongs_to :author, class_name: User.to_s
  belongs_to :committer, class_name: User.to_s
  belongs_to :pusher, class_name: User.to_s

  has_many :ontology_versions
  has_many :ontologies, through: :ontology_versions

  belongs_to :repository

  def fill_commit_instance!
    commit = repository.git.repo.lookup(commit_oid)

    data = commit.author
    self.author_name = data[:name]
    self.author_email = data[:email]
    self.author_date = data[:time]
    self.author = User.where(email: author_email).first

    data = commit.committer
    self.committer_name = data[:name]
    self.committer_email = data[:email]
    self.commit_date = data[:time]
    self.committer = User.where(email: committer_email).first

    save!
  end
end
