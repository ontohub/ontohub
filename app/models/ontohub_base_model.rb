class OntohubBaseModel < ActiveRecord::Base
 @abstract_class = true
 has_many :loc_ids, as: assorted_object

 def self.find_with_locid(locid, _iri = nil)
   result = LocID.where(locid: locid).first.try(:assorted_object)

   if result.nil? && iri
     ontology = AlternativeIri.where('iri LIKE ?', '%' << iri).
       first.try(:ontology)
   end
   result
 end

end
