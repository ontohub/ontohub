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
    @repositories = Repository.active.accessible_by(current_user)
    super
  end

  def destroy
    if resource.can_be_deleted?
      resource.destroy_asynchronously
      redirect_to repositories_path
    else
      flash[:error] = I18n.t('repository.delete_error')
      redirect_to resource
    end
  end

  protected

  def collection
    super.order(:name)
  end

end
