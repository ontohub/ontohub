# 
# Displays a user profile
# 
class UsersController < InheritedResources::Base
  
  def show
    @versions = resource.ontology_versions.order('id DESC').limit(10).all
  end
  
end
