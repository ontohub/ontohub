class RepositoriesController < InheritedResources::Base

  defaults finder: :find_by_path!

  load_and_authorize_resource :except => [:index, :show]

  def create
    resource.user = current_user
    super
  end

  protected

  def collection
    super.order(:name)
  end

end
