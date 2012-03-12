# 
# Base-Controller for editing a permission list
# Please subclass this controller for your implementation
# 
class PrivilegeList::Base < InheritedResources::Base
  
  actions :create, :update, :destroy
  rescue_from Permission::PowerVaccuumError, :with => :power_error
  
  def create
    build_resource.save!
    respond_to do |format|
      format.html { render_resource }
    end
  end
  
  def update
    resource.update_attributes! *resource_params
    respond_to do |format|
      format.html { render_resource }
    end
  end
  
  def destroy
    resource.destroy
    head :ok
  end
  
  protected
  
  helper_method :permission_list
  def permission_list
    raise NotImplementedError
    # you need to override this method with something like:
    # @permission_list ||= PermissionList.new ...
  end
  
  def render_resource
    render :partial => resource, :locals => {:permission_list => permission_list}
  end
  
  def power_error(exception)
    render :text => exception.message, :status => :unprocessable_entity
  end
  
end