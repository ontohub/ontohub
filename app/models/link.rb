class Link < ActiveRecord::Base
  include Permissionable
  include Metadatable

  KINDS = %w( import alignment view hiding minimization cofree free )
  DEFAULT_LINK_KIND = KINDS.first
  KINDS_MAPPING = {
    'GlobalDef' => 'import',
    'GlobalDefInc' => 'import',
    'Thm' => 'view',
  }

  CONS_STATUSES = %w( inconsistent none cCons mcons mono def )

  belongs_to :ontology
  belongs_to :source, class_name: 'Ontology'
  belongs_to :target, class_name: 'Ontology'
  belongs_to :logic_mapping
  belongs_to :link_version
  has_many :entity_mappings

  has_many :versions,
      :dependent  => :destroy,
      :order      => :version_number,
      :class_name => 'LinkVersion' do
        def current
          reorder('version_number DESC').first
        end
      end

  attr_accessible :iri, :source, :target, :kind, :theorem, :proven, :local,
                  :inclusion, :logic_mapping, :parent, :ontology_id, :source_id,
                  :target_id, :versions_attributes, :versions, :name
  accepts_nested_attributes_for :versions

  def self.with_ontology_reference(ontology_id)
    Link.where('ontology_id = ? OR source_id = ? OR target_id = ?',
                          ontology_id, ontology_id, ontology_id)
  end

  def current_version
    if self.link_version
      self.link_version
    else
      self.versions.current
    end
  end

  def update_version!(to: nil)
    self.link_version_id = to ? to.id : versions.current.id
    save!
  end

  def to_s
    string = ""
    if name
      string = name
    else
      array = iri.split("?")
      string = array.last
    end
    string
  end

  def display_connection
    if theorem
      if proven
        "badge badge-success"
      else
        "badge badge-important"
      end
    else
      "badge badge-inverse"
    end
  end

  def get_entity
    if entity_mappings.size > 1
      "#{entity_mappings.first}..."
    else
      "#{entity_mappings.first}"
    end
  end
end
