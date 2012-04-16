class EntityMappings < ActiveRecord::Base
  belongsto :source
  belongsto :target
  belongsto :link_version
end
