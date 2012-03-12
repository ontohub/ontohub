class Permission < ActiveRecord::Base
  
  ROLES = %w(owner editor)
  
  # thrown if the last admin/owner tries to remove itself
  class PowerVaccuumError < Exception; end
  
  attr_accessible :subject, :subject_id, :subject_type, :role
  
  belongs_to :subject, :polymorphic => true
  belongs_to :item, :polymorphic => true
  
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
  
end
