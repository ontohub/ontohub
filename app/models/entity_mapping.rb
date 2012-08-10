class EntityMapping < ActiveRecord::Base
  belongs_to :source
  belongs_to :target
  belongs_to :link_version
  
  KINDS = %w( subsumes is-subsumed equivalent incompatible has-instance instance-of default-relation )

end
