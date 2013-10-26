class RepositoriesController < InheritedResources::Base

  defaults finder: :find_by_path!

  load_and_authorize_resource :except => [:index, :show]

  def create
    resource.user = current_user
    super
  end

end
