class Permission < ActiveRecord::Base
  MINIMAL_OWNER_COUNT = 1
  ROLES = %w(owner editor reader)

  # thrown if the last admin/owner tries to remove itself
  class PowerVaccuumError < StandardError; end

  class OwnerCountValidator < ActiveModel::Validator
    def validate(record)
      if record.degrading_owner? && record.minimal_owner_count_reached?
        record.errors[:item_id] = I18n.t('permission.errors.falling_short_of_owner_count',
          minimal_count: MINIMAL_OWNER_COUNT,
          item: record.item.class)
      end
    end
  end

  validates_with OwnerCountValidator

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

  def destroy
    if self.role == 'owner' && self.minimal_owner_count_reached?
      raise PowerVaccuumError, I18n.t('permission.errors.falling_short_of_owner_count',
            minimal_count: MINIMAL_OWNER_COUNT,
            item: self.item.class)
    end
    super
  end

  def was_already_owner?
    self.persisted? && self.role_was == 'owner'
  end

  def minimal_owner_count_reached?
    self.item.permissions.owner.size <= MINIMAL_OWNER_COUNT
  end

  def degrading_owner?
    self.was_already_owner? && self.role_changed?
  end

end
