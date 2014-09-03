class RepositoriesController < InheritedResources::Base

  respond_to :html, :text

  defaults finder: :find_by_path!

  load_and_authorize_resource :except => [:index]

  def create
    resource.user = current_user
    super
  end

  def update
    params[:repository].except!(:source_address, :source_type, :name)
    super
  end

  def index
    @repositories = Repository.accessible_by(current_user)
    super
  end

  def destroy
    if resource.can_be_deleted?
      resource.destroy_asynchonously
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
