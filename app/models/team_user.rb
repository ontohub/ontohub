class TeamUser < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  attr_accessible :user, :admin
  attr_accessible :user_id, :team_id

  before_create :set_admin_if_owner

protected

  def set_admin_if_owner
    self.admin = true if !admin && team.users.empty?
  end
end
