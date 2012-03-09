class Team < ActiveRecord::Base
  
  has_many :team_users
  has_many :users, :through => :team_users
  
  # create admin user after team creation
  attr_accessor :admin_user
  after_create :create_admin_user
  
  attr_accessible :name
  
  scope :autocomplete_search, ->(query) {
    limit(10).where("name ILIKE ?", "%" << query << "%")
  }
  
  validates :name, :uniqueness => { :case_sensitive => false }
  
  def to_s
    name
  end
  
  protected
  
  # create admin user after team-creation
  def create_admin_user
    if admin_user
      team_users.create! \
        admin: true,
        user:  admin_user
    end
  end
  
end
