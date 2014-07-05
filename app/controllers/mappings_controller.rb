#
# Controller for Mappings
#
class MappingsController < InheritedResources::Base

  def edit
    edit!
    @source = resource.source
  end

  def destroy
    destroy! do |format|
      format.html { redirect_to root_path }
    end
  end

end
