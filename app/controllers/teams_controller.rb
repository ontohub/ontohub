#
# Displays all teams of the current users and creates new ones.
#
class TeamsController < InheritedResources::Base

  respond_to :json, :xml
  load_and_authorize_resource

  def show
    super do |format|
      format.html do
        # users of current team
        @team_users = resource.team_users.joins(:user).order(:name).all
      end
    end
  end

  def create
    build_resource.admin_user = current_user
    super
  end

  protected

  def collection
    # show only teams of current user
    @team_users ||= current_user.team_users.joins(:team).order(:name).all
  end

end
