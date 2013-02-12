# 
# Controller for LanguageMappings
# 
class LanguageMappingsController < MappingsController
#  belongs_to :source, :class_name => "Language"
#  belongs_to :target, :class_name => "Language"
  belongs_to :language
  
  load_and_authorize_resource :except => [:index, :show]
  
  def destroy
    destroy! do |format|
      format.html { redirect_to parent_path }
    end
  end
  
  def create
    @language_mapping.user = current_user
    super
  end
  
end