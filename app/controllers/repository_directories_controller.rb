class RepositoryDirectoriesController < InheritedResources::Base
  actions :new, :create

  helper_method :repository
  before_filter :check_write_permissions, only: [:new, :create]
  before_filter :check_read_permissions

  def create
    if resource.valid?
      resource.save
      render json: create_json_data, status: 201
    else
      render partial: 'form', status: 422
    end
  end

  protected

  def resource
    @repository_directory ||= RepositoryDirectory.new(params.merge(
      user: current_user))
  end

  def repository
    @repository ||= resource.repository
  end

  def create_json_data
    created_directories = resource.created_directories
    if created_directories.size > 1
      additional_text = t('repository_directory.create_additional',
        directories: created_directories.map { |d| "\"#{d}\"" }.join(', '))
    end
    {
      text: "#{t('repository_directory.create', name: resource.name)} #{additional_text}",
      link: {
        url: fancy_repository_path(repository, path: resource.path),
        text: resource.name
      }
    }
  end

  def check_read_permissions
    authorize! :show, repository
  end

  def check_write_permissions
    authorize! :write, repository
  end
end
