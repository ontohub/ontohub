class TeamUser < ActiveRecord::Base

  belongs_to :team
  belongs_to :user
  belongs_to :creator, :class_name => 'User'

  attr_accessible :user, :admin
  attr_accessible :user_id, :team_id

  before_create  :set_admin_if_first_member
  before_update  :check_remaining_admins_on_update
  before_destroy :check_remaining_admins_on_destroy

  scope :admin, where(:admin => true)
  scope :non_admin, where(:admin => false)

  delegate :team_users, :to => :team

  def team_users
    self.class.where(:team_id => team_id)
  end

  protected

  def set_admin_if_first_member
    self.admin = true if !admin && team_users.empty?
  end

  def check_remaining_admins_on_update
    check_remaining_admins if admin_changed? && !admin? # admin-flag removed?
  end

  def check_remaining_admins_on_destroy
    check_remaining_admins if admin? # is admin on destroy?
  end

  def check_remaining_admins
    if team_users.admin.count < 2
      raise Permission::PowerVaccuumError, "What the hell ... nobody cares for your group if you remove the only one admin!"
    end
  end

end
