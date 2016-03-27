class LocIdBaseModel < ActiveRecord::Base
  @abstract_class = true
  has_many :loc_ids, as: :assorted_object
  before_destroy :destroy_locid

  def self.find_with_locid(locid, _iri = nil)
    result = LocId.where(locid: locid).first.try(:assorted_object)
    if table_name == "ontologies"
      if result.nil? && iri
        result = AlternativeIri.where('iri LIKE ?', '%' << iri).
          first.try(:ontology)
      end
    end
    result
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
      LocId.create(assorted_object_id: id,
                   assorted_object_type: self.class.to_s,
                   locid: string)
    end
  end

  def query_locid
    LocId.where(assorted_object_id: id,
                assorted_object_type: normalized_class.to_s)
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
