class LocIdBaseModel < ActiveRecord::Base
  @abstract_class = true
  after_create :create_locid
  before_destroy :destroy_locid

  # There is no polymorphic has_one
  has_many :loc_ids, as: :specific

  default_scope { joins(:loc_ids) }

  def self.find_with_locid(locid, iri = nil)
    result = LocId.where(locid: locid).first.try(:specific)
    if table_name == 'ontologies' && result.nil? && iri
      result = AlternativeIri.where('iri LIKE ?', '%' << iri).
        first.try(:ontology)
    end
    result
  end

  def create_locid
    LocId.where(locid: generate_locid_string,
                specific_id: id,
                specific_type: normalized_class.to_s).first_or_create!
  end

  # To be overwritten in the subclasses.
  def generate_locid_string
    nil
  end

  def destroy_locid
    # When reanalysing an ontology in the migrations (because of duplicates),
    # the locid can already be nil.
    loc_ids.first.try(:destroy)
  end

  def locid
    loc_ids.first.try(:locid)
  end

  def locid=(string)
    if locid = loc_ids.first
      locid.update_attributes(locid: string)
    else
      LocId.create(specific_id: id,
                   specific_type: normalized_class.to_s,
                   locid: string)
    end
  end

  def normalized_class
    # Sometimes the objects are "Ontology" and sometimes a subclass.
    if [DistributedOntology, SingleOntology].include?(self.class)
      Ontology
    elsif Sentence.descendants.include?(self.class)
      Sentence
    else
      self.class
    end
  end
end
