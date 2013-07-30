class EntityMapping < ActiveRecord::Base
  belongs_to :source
  belongs_to :target
  belongs_to :link
  
  KINDS = %w( subsumes is-subsumed equivalent incompatible has-instance instance-of default-relation )

end
