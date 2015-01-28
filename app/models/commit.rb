class Commit < ActiveRecord::Base
  attr_accessible :commit_oid, :repository
  attr_accessible :author, :author_date
  attr_accessible :commit_date, :committer

  belongs_to :repository
end
