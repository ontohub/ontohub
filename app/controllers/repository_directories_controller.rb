class RepositoryDirectoriesController < InheritedResources::Base
  actions :new, :create

  helper_method :repository
  before_filter :check_write_permissions, only: [:new, :create]
  before_filter :check_read_permissions

  def create
    if resource.valid?
      resource.save
      flash[:success] = "Successfully created the subdirectory."
      redirect_to fancy_repository_path(repository, path: resource.target_path)
    else
      render :new
    end
  end

  protected

  def resource
    @repository_directory ||= RepositoryDirectory.new(params.merge(user: current_user))
  end

  def repository
    @repository ||= resource.repository
  end

  def check_read_permissions
    authorize! :show, repository
  end

  def check_write_permissions
    authorize! :write, repository
  end
end
