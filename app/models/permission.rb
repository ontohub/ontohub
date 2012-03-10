class Permission < ActiveRecord::Base
  belongs_to :subject, :polymorphic => true
  belongs_to :item, :polymorphic => true

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
end
