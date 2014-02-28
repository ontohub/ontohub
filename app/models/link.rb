class Link < ActiveRecord::Base
  include Permissionable
  include Metadatable

  KINDS = %w( alignment import view hiding minimization free cofree )
  
  CONS_STATUSES = %w( inconsistent none cCons mcons mono def )
  
  belongs_to :ontology
  belongs_to :source, class_name: 'Ontology'
  belongs_to :target, class_name: 'Ontology'
  belongs_to :logic_mapping
  belongs_to :current_version
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
