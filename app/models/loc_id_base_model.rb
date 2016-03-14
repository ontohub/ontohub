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
     LocId.where(assorted_object_id: self.id, assorted_object_type: self.class).first.destroy
 end

 def locid
   LocId.where(assorted_object_id: self.id, assorted_object_type: self.class).first.try(:locid)
 end

 def locid=(string)
   locid = LocId.where(assorted_object_id: self.id, assorted_object_type: self.class).first
   if locid
     locid.update_attributes(locid: string)
   else
     LocId.create(assorted_object_id: self.id,
                  assorted_object_type: self.class,
                  locid: string,
                 )
   end
 end
end
