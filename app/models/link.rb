class Link < ActiveRecord::Base
  include Permissionable
  include Metadatable

  KINDS = %w( view import alignment hiding_import minimization )
  
  belongs_to :source
  belongs_to :target
  belongs_to :current_version
  has_many :link_versions
end
