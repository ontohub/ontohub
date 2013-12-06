# 
# The home page that displays all latest news
# 
class HomeController < ApplicationController
  
  def show
    @comments = Comment.latest.limit(10).all
    @versions = OntologyVersion.latest.where(state: 'done').limit(10).all
    @repositories = Repository.accessible_by(current_user).latest.limit(10).all
  end
  
end
