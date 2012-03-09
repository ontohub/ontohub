class Team < ActiveRecord::Base
  has_many :team_users
  has_many :users, :through => :team_users
  
  scope :autocomplete_search, ->(query) {
    limit(10).where("name ILIKE ?", "%" << query << "%")
  }
  
end
