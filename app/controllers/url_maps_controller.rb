class UrlMapsController < InheritedResources::Base

  belongs_to :repository, finder: :find_by_path!
  before_filter :check_write_permission, :except => [:index, :show]
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

  helper_method :repository
  def repository
    resource.repository
  end

end
