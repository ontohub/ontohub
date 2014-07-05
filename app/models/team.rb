class Team < ActiveRecord::Base

  has_many :team_users
  has_many :users, :through => :team_users
  has_many :permissions, :as => :subject

  # create admin user after team creation
  attr_accessor   :admin_user
  attr_accessible :admin_user
  after_create    :create_admin_user

  attr_accessible :name

  strip_attributes :only => :name

  scope :autocomplete_search, ->(query) {
    where("name ILIKE ?", "%" << query << "%")
  }

  validates :name,
    :presence   => true,
    :length     => { :minimum => 3, :maximum => 50 },
    :uniqueness => { :case_sensitive => false }

  def to_s
    name
  end

  # does the given user have admin-privileges in this team?
  def admin?(user)
    user && (user.admin? || team_users.admin.find_by_user_id(user.id))
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
