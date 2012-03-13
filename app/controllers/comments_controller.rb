class CommentsController < InheritedResources::Base
  
  belongs_to :ontology, :polymorphic => true
  
  actions :index, :create
  
  def create
    authorize! :create, build_resource
    resource.user = current_user
    
    super do |format|
      format.html do
        if resource.errors.empty?
          render :partial => resource
        else
          render :partial => 'form', :status => :unprocessable_entity
        end
      end
    end
  end
  
  def destroy
    authorize! :destroy, resource
    resource.destroy
    head :ok
  end
  
end
