#
# Base-Controller for editing a permission list
# Please subclass this controller for your implementation
#
class PrivilegeList::Base < InheritedResources::Base

  actions :index, :create, :update, :destroy, :show
  respond_to :json, :xml
  rescue_from Permission::PowerVaccuumError, :with => :power_error

  before_filter :authorize_parent

  def create
    build_resource.creator = current_user if build_resource.respond_to? :creator
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

  def authorize_parent
    raise NotImplementedError
  end

  helper_method :relation_list
  def relation_list
    raise NotImplementedError
    # you need to override this method with something like:
    # @relation_list ||= RelationList.new ...
  end

  def render_resource
    render :partial => resource, :locals => {:relation_list => relation_list}
  end

  def power_error(exception)
    render :text => exception.message, :status => :unprocessable_entity
  end

end
