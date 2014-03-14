class RepositorySettingsController < InheritedResources::Base
  belongs_to :repository, finder: :find_by_path!
  
  def index
    repo = Repository.find_by_path(params[:repository_id])
    redirect_to repository_url_maps_path
  end
end
