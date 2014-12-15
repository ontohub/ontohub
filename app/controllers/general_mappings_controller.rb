#
# Controller for {Language,Logic}Mappings
#
class GeneralMappingsController < InheritedResources::Base

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
