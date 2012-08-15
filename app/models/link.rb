class Link < ActiveRecord::Base
  include Permissionable
  include Metadatable

  KINDS = %w( alignment import_or_view hiding minimization free cofree )
  CONS_STATUSES = %w( inconsistent none cCons mcons mono def )
  
  belongs_to :source
  belongs_to :target
  belongs_to :current_version
  has_many :link_versions
  
  attr_accessible :iri, :source, :target, :kind, :theorem, :proven, :local,
                  :inclusion, :logic_mapping, :parent, :ontology_id
end
