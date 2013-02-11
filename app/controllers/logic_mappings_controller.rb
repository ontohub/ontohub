# 
# Controller for LogicMappings
# 
class LogicMappingsController < MappingsController
  belongs_to :logic
  
  def destroy
    puts "###########################################################"
    source_path = parent_url
    destroy!
    redirect_to source_path
  end
end