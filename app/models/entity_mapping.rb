class EntityMapping < ActiveRecord::Base
  belongs_to :source, class_name: "Entity"
  belongs_to :target, class_name: "Entity"
  belongs_to :link
  attr_accessible :link, :source, :target
  KINDS = %w( subsumes is-subsumed equivalent incompatible has-instance instance-of default-relation )

  def to_s
   "#{self.source} → #{self.target}"
  end
end
