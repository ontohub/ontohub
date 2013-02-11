# 
# Controller for Mappings
# 
class MappingsController < InheritedResources::Base
  
  def edit
    edit!
    @logic = resource.source
  end
  
end