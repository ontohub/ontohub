class Permission < ActiveRecord::Base

  ROLES = %w(owner editor reader)

  # thrown if the last admin/owner tries to remove itself
  class PowerVaccuumError < StandardError; end

  attr_accessible :subject, :subject_id, :subject_type, :role

  # user/team that receives the permission
  belongs_to :subject, :polymorphic => true

  # item that the user/team is permitted to
  belongs_to :item, :polymorphic => true

  # the user who created the permission
  belongs_to :creator, :class_name => 'User'

  validates_inclusion_of :role, :in => ROLES

  scope :item, ->(item) {
    where \
      item_id:   item.id,
      item_type: item.class.to_s
  }

  scope :subject, ->(subject) {
    where \
      subject_id:   subject.id,
      subject_type: subject.class.to_s
  }

  scope :role, ->(role) { where :role => role }
  scope :owner, role(:owner)
  scope :editor, role(:editor)
  scope :reader, role(:reader)

  # reduce the comparison problem to
  # a number comparison problem by
  # using an array
  def permissions_order(b)
    a = self
    a_role, b_role = a.role, b.role
    order = %w{reader editor owner}
    a_index = order.index(a_role) || -1
    b_index = order.index(b_role) || -1
    a_index <=> b_index
  end


end
