# 
# Controller for Mappings
# 
class MappingsController < InheritedResources::Base
  
  def edit
    edit!
    @source = resource.source
  end
  
end