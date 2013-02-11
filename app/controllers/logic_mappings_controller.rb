# 
# Controller for LogicMappings
# 
class LogicMappingsController < MappingsController
#  belongs_to :source, :class_name => "Logic"
#  belongs_to :target, :class_name => "Logic"
  belongs_to :logic
  
  load_and_authorize_resource :except => [:index, :show]
  
  def destroy
    destroy! do |format|
      format.html { redirect_to parent_path }
    end
  end
  
  def create
    @logic_mapping.user = current_user
    super
  end
  
end