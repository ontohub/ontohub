class RepositoriesController < InheritedResources::Base

  respond_to :html, :text

  defaults finder: :find_by_path!

  load_and_authorize_resource :except => [:index]

  def create
    resource.user = current_user
    unless params[:source_address]
      params[:repository].except!(:source_type, :remote_type)
    end
    super
  end

  def update
    resource.convert_to_local! if params[:un_mirror]
    params[:repository].
      except!(:source_address, :source_type, :remote_type, :name)
    super
  end

  def index
    @repositories = Repository.accessible_by(current_user)
    super
  end

  def destroy
    resource.destroy_asynchronously
    redirect_to repositories_path
  rescue Repository::DeleteError => e
    flash[:error] = e.message
    redirect_to resource
  end

  def undestroy
    resource.undestroy
    begin
      resource.reload
      flash[:success] = t('repository.undestroy.success')
      redirect_to resource
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = t('repository.undestroy.failure')
      redirect_to Repository
    end
  end

  protected

  def resource
    path = params[:repository_id] || params[:id]
    @repository ||= Repository.find_by_path(path)
  end

  def collection
    super.order(:name)
  end
end
