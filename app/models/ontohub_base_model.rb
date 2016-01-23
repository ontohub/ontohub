class OntohubBaseModel < ActiveRecord::Base
 @abstract_class = true
 has_many :loc_ids, as: :assorted_object

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

 def locid
   LocId.where(assorted_object_id: self.id, assorted_object_type: Ontology).first.try(:locid)
 end
end
