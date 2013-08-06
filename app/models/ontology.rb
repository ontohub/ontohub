class Ontology < ActiveRecord::Base

  # Ontohub Library Includes  
  include Commentable
  include Permissionable
  include Metadatable

  # Ontology Model Includes
  include Ontology::Import
  include Ontology::States
  include Ontology::Versions
  include Ontology::Entities
  include Ontology::Sentences
  include Ontology::Links
  include Ontology::Distributed
  include Ontology::Oops

  belongs_to :language
  belongs_to :logic, counter_cache: true

  attr_accessible :iri, :name, :description, :logic_id

  validates_presence_of :iri
  validates_uniqueness_of :iri, :if => :iri_changed?
  validates_format_of :iri, :with => URI::regexp(Settings.allowed_iri_schemes)
  
  strip_attributes :only => [:name, :iri]

  scope :search, ->(query) { where "ontologies.iri #{connection.ilike_operator} :term OR ontologies.name #{connection.ilike_operator} :term", :term => "%" << query << "%" }
  scope :list, includes(:logic).order('ontologies.state asc, ontologies.entities_count desc')

  def to_s
    name? ? name : iri
  end
  
  # title for links
  def title
    name? ? iri : nil
  end

  def symbols
    entities
  end

  def symbols_count
    entities_count
  end

  def active_version
    return self.ontology_version if self.state == 'done'
    OntologyVersion.
      where(ontology_id: self, state: 'done').
      order('number DESC').
      first
  end

  def non_current_active_version?(user=nil)
    real_process_state = active_version != self.ontology_version
    if user && (user.admin || ontology_version.user == user)
      real_process_state
    else
      false
    end
  end

  def self.with_active_version
    state = "done"
    includes(:versions).
    where([
      "ontologies.id IN " +
      "(SELECT ontology_id FROM ontology_versions WHERE state = ?)",
      state
    ])
  end

  def self.in_process(user=nil)
    return [] if user.nil?
    state = "done"
    stmt = ['state != ?', state] if user == true
    if user.is_a?(User)
      stmt = ['state != ? AND ' +
        'ontologies.id IN (SELECT ontology_id FROM ontology_versions ' +
        'WHERE user_id = ?)', state, user.id]
    end
    includes(:versions).
    where(stmt)
  end

end
