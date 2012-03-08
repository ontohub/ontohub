class TeamUser < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  before_create :set_admin_if_owner

  def set_admin_if_owner
    self.admin = true if team.users.empty?
  end
end
