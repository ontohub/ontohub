class EntityMapping < ActiveRecord::Base
  belongs_to :source, class_name: "Entitiy"
  belongs_to :target, class_name: "Entitiy"
  belongs_to :link
  
  KINDS = %w( subsumes is-subsumed equivalent incompatible has-instance instance-of default-relation )

end
