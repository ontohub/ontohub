class LocIdBaseModel < ActiveRecord::Base
  @abstract_class = true
  has_many :loc_ids, as: :specific
  after_create :create_locid
  before_destroy :destroy_locid

  def self.find_with_locid(locid, _iri = nil)
    result = LocId.where(locid: locid).first.try(:specific)
    if table_name == "ontologies"
      if result.nil? && iri
        result = AlternativeIri.where('iri LIKE ?', '%' << iri).
          first.try(:ontology)
      end
    end
    result
  end

  def create_locid
    LocId.where(locid: generate_locid_string,
                specific_id: id,
                specific_type: normalized_class.to_s,
               ).first_or_create!
  end

  # To be overwritten in the subclasses.
  def generate_locid_string
    nil
  end

  def destroy_locid
    query_locid.first.destroy
  end

  def locid
    query_locid.first.try(:locid)
  end

  def locid=(string)
    if locid = query_locid.first
      locid.update_attributes(locid: string)
    else
      LocId.create(specific_id: id,
                   specific_type: normalized_class.to_s,
                   locid: string)
    end
  end

  def query_locid
    LocId.where(specific_id: id,
                specific_type: normalized_class.to_s)
  end

  def normalized_class
    # Sometimes the objects are "Ontology" and sometimes a subclass.
    if [DistributedOntology, SingleOntology].include?(self.class)
      Ontology
    else
      self.class
    end
  end
end
