class Link < ActiveRecord::Base
  include Permissionable
  include Metadatable

  KINDS = %w( alignment import_or_view hiding minimization free cofree )
  CONS_STATUSES = %w( inconsistent none cCons mcons mono def )
  
  belongs_to :source
  belongs_to :target
end
