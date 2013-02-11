class SupportsController < InheritedResources::Base
  
  def create
    build_resource.logic = Logic.find(params[:logic_id])
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
  
  helper_method :relation_list
  def relation_list
    raise NotImplementedError
    # you need to override this method with something like:
    # @relation_list ||= RelationList.new ...
  end
  
  def render_resource
    render :partial => resource, :locals => {:relation_list => relation_list}
  end
  
end
