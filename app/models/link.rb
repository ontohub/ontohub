class Link < ActiveRecord::Base
  include Permissionable
  include Metadatable

  belongs_to :source
  belongs_to :target
end
