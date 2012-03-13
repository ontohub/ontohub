# 
# Displays a user profile
# 
class UsersController < InheritedResources::Base
  
  def show
    @versions = resource.ontology_versions.latest.limit(10).all
    @comments = resource.comments.latest.limit(10).all
  end
  
end
