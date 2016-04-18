#
# The home page that displays all latest news
#
class HomeController < ApplicationController

  def index
    @comments = Comment.latest.limit(10)
    @versions = OntologyVersion.accessible_by(current_user).latest.
      where(state: 'done').limit(10)
    @repositories = Repository.accessible_by(current_user).latest.limit(10)
  end

  def show

  end

end
