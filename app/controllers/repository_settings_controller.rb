class RepositorySettingsController < InheritedResources::Base
  belongs_to :repository, finder: :find_by_path!
  
  def index
    repo = Repository.find_by_path(params[:repository_id])
  end
end
