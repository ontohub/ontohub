class UrlMapsController < InheritedResources::Base

  belongs_to :repository, finder: :find_by_path!
  before_filter :check_write_permission, :except => [:index, :show]
  before_filter :check_read_permissions
  has_pagination

  def create
    create! { repository_url_maps_path(repository) }
  end

  def update
    update! { repository_url_maps_path(repository) }
  end

  def destroy
    destroy! { repository_url_maps_path(repository) }
  end

  protected

  def check_write_permission
    authorize! :write, parent
  end

  def check_read_permissions
    authorize! :show, Repository.find_by_path(params[:repository_id])
  end

  helper_method :repository
  def repository
    if action_name == "index"
      Repository.find_by_path(params[:repository_id])
    else
      resource.repository
    end
  end

end
