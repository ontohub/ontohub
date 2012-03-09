class Permission < ActiveRecord::Base
  belongs_to :subject, :polymorphic => true
  belongs_to :object, :polymorphic => true

  scope :find, ->(o, s) {
    where object_id:  o.id, object_type:  o.class.to_s,
          subject_id: s.id, subject_type: s.class.to_s
  }
end
