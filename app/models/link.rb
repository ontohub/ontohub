class Link < ActiveRecord::Base
  include Permissionable
  include Metadatable

  KINDS = %w( alignment import_or_view hiding minimization free cofree )
  KIND_DEFAULT = 'import_or_view'
  
  CONS_STATUSES = %w( inconsistent none cCons mcons mono def )
  
  belongs_to :ontology
  belongs_to :source, class_name: 'Ontology'
  belongs_to :target, class_name: 'Ontology'
  belongs_to :logic_mapping
  belongs_to :current_version
  has_many :link_versions
  
  attr_accessible :iri, :source, :target, :kind, :theorem, :proven, :local,
                  :inclusion, :logic_mapping, :parent, :ontology_id
end
