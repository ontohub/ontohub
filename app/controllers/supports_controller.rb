# 
# Controller for Supports
# 
class SupportsController < PrivilegeList::Base
  
  nested_belongs_to :logic
  
  protected
  
  def authorize_parent
    #not needet! but has to be implemented for PrivilegeList
  end
  
  def relation_list
    @relation_list ||= RelationList.new [parent, :supports],
          :model       => Support,
          :collection  => parent.supports,
          :association => :language,
          :scope       => [Language]
  end
  
end
