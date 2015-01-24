class Mapping < ActiveRecord::Base
  include Permissionable
  include Metadatable

  KINDS = %w( import alignment view hiding minimization cofree free )
  DEFAULT_MAPPING_KIND = KINDS.first
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
  belongs_to :mapping_version
  has_many :symbol_mappings

  has_many :versions,
      dependent:   :destroy,
      order:       :version_number,
      class_name:  'MappingVersion' do
        def current
          reorder('version_number DESC').first
        end
      end

  attr_accessible :locid
  attr_accessible :iri, :source, :target, :kind, :theorem, :proven, :local,
                  :inclusion, :logic_mapping, :parent, :ontology_id, :source_id,
                  :target_id, :versions_attributes, :versions, :name
  accepts_nested_attributes_for :versions

  def self.with_ontology_reference(ontology_id)
    Mapping.where('ontology_id = ? OR source_id = ? OR target_id = ?',
                          ontology_id, ontology_id, ontology_id)
  end

  def current_version
    if mapping_version
      mapping_version
    else
      versions.current
    end
  end

  def update_version!(to: nil)
    self.mapping_version_id = to ? to.id : versions.current.id
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

  def symbol
    if symbol_mappings.size > 1
      "#{symbol_mappings.first}..."
    else
      "#{symbol_mappings.first}"
    end
  end
end
