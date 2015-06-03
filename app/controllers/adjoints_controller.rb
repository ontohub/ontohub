#
# Controller for Adjoints
#
class AdjointsController < InheritedResources::Base

  def edit
    edit!
    @source = resource.translation
  end

  def destroy
    destroy! do |format|
      format.html { redirect_to root_path }
    end
  end

end
