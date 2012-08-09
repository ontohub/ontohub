class Link < ActiveRecord::Base
  include Permissionable
  include Metadatable

  KINDS = %w( alignment import_or_view hiding minimization free cofree )
  CONS_STATUSES = %w( inconsistent none cCons mcons mono def )
  
  belongs_to :source
  belongs_to :target
  belongs_to :current_version
  has_many :link_versions
end
